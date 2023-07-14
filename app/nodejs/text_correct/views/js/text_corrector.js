/* custom functions for the text corrector
   reads and compares changes and call the language model assistant */
import {mail2string,block_distance} from './text_utils.js';

var prev_email = new Object();
var curr_email = new Object();
var curr_prompt = new Object();
var curr_style = new Object();
var prevS = '';
var currS = '';
var prompS = '';
var requestS = "Can you improve the following sentence for an outreach email, here I'm ";
var promptD = {
  "model": "gpt-4",
  "messages": [{"role": "user", "content": "Say this is a test!"}],
  "temperature": 0.7
}
var blockD = {"id":"subject","block":0}
var initMail = {"time":Date.now(),"version":"start","blocks" : [
  {"id":"subject","type":"header","data":{"text":"Update on the new feature of our Saas product."}}
  ,{"id":"greeting","type":"paragraph","data":{"text":"Dear Customer,"}}
  ,{"id":"presentation","type":"paragraph","data":{"text":"I'm the customer success manager of the software company xy"}}
  ,{"id":"value proposition","type":"paragraph","data":{"text":"and I'm happy to announce we have released a brand new feature allowing correction of outreach emails."}}
  ,{"id":"personalization","type":"paragraph","data":{"text":"Especially for you we are applying a discount of 20%."}}
  ,{"id":"goodbye","type":"paragraph","data":{"text":"Sincerely"}}
  ,{"id":"signature","type":"paragraph","data":{"text":"John Doe"}}
]};

var initStyle = {"time":Date.now(),"version":"start","blocks" : [
  {"id":"subject","type":"paragraph","data":{"text":requestS + "writing the title"}}
  ,{"id":"greeting","type":"paragraph","data":{"text":requestS + "greeting the customer"}}
  ,{"id":"presentation","type":"paragraph","data":{"text":requestS + "introducing myself"}}
  ,{"id":"value proposition","type":"paragraph","data":{"text":requestS + "explaining our value proposition"}}
  ,{"id":"personalization","type":"paragraph","data":{"text":requestS + "making a personalized offer to the client"}}
  ,{"id":"goodbye","type":"paragraph","data":{"text":requestS + "saying goodbye to the customer"}}
  ,{"id":"signature","type":"paragraph","data":{"text":requestS + "writing my signature"}}
]};

var initPrompt = {"time":Date.now(),"version":"start","blocks" : [
  {"id":"title","type":"paragraph","data":{"text":"I need to write a commercial email"}}
  ,{"id":"greeting","type":"paragraph","data":{"text":"to a lead named 'Frank' I don't know personally."}}
  ,{"id":"presentation","type":"paragraph","data":{"text":"I'm the customer success manager of the company xy."}}
  ,{"id":"value proposition","type":"paragraph","data":{"text":"I want to promote a new feature of our software allowing correction of outreach emails."}}
  ,{"id":"personalization","type":"paragraph","data":{"text":"I want to apply a discount of 20% to this customer."}}
  ,{"id":"goodbye","type":"paragraph","data":{"text":"I want a polite goodbye and be concise."}}
]}

let genMail = "Subject: Introducing Our New Feature: Correct Outreach Emails Effortlessly\n\nDear Frank,\n\nI hope this email finds you well. As the Customer Success Manager at XY, I wanted to reach out to you to introduce an exciting new feature that can greatly enhance your outreach efforts.\n\nWe have recently launched a powerful addition to our software that allows for easy correction and editing of outbound emails. This feature enables you to quickly rectify any mistakes or make necessary revisions before sending them out, ensuring that your communication remains professional and error-free.\n\nUnderstanding the value this new feature brings to our customers, we would like to extend a special offer to you. As a token of appreciation for your interest in XY and to encourage you to explore this new capability, we are delighted to offer you an exclusive 20% discount on the purchase of this feature. This discount is applicable for a limited time only, so it's a great opportunity to take advantage of this valuable addition to our software suite.\n\nTo claim your discount, simply use the coupon code NEWEMAIL20 during the checkout process. Don't miss out on this chance to optimize your outreach efforts and improve your communication effectiveness.\n\nIf you have any questions or would like further information about this feature, please feel free to reach out to me directly. I'm more than happy to assist you in any way I can.\n\nThank you for your time and consideration, Frank. We appreciate your continued support as a valued lead of XY. Should you have any other requirements or needs, please do not hesitate to let me know. \n\nWishing you a successful and productive day ahead!\n\nBest regards,\n\n[Your Name]\nCustomer Success Manager\nXY";

class textCorrect {
  static get toolbox() {
    return {
      title: 'Image',
      icon: '<svg width="17" height="15" viewBox="0 0 336 276" xmlns="http://www.w3.org/2000/svg"><path d="M291 150V79c0-19-15-34-34-34H79c-19 0-34 15-34 34v42l67-44 81 72 56-29 42 30zm0 52l-43-30-56 30-81-67-66 39v23c0 19 15 34 34 34h178c17 0 31-13 34-29zM79 0h178c44 0 79 35 79 79v118c0 44-35 79-79 79H79c-44 0-79-35-79-79V79C0 35 35 0 79 0z"/></svg>'
    };
  }
  render(){
    return document.createElement('input');
  }
  save(blockContent){
    return {
      url: blockContent.value
    }
  }
}

class markerTool {
  static get isInline(){ return true; }
  constructor() {
    this.button = null;
    this.state = false;
  }
  render() {
    this.button = document.createElement('button');
    this.button.type = 'button';
    this.button.textContent = 'M';
    return this.button;
  }
  surround(range) {
    if (this.state) {return;}
    const selectedText = range.extractContents();
    const mark = document.createElement('MARK');
    mark.appendChild(selectedText);
    range.insertNode(mark);
  }
  checkState(selection) {
    const text = selection.anchorNode;
    if (!text) {return;}
    const anchorElement = text instanceof Element ? text : text.parentElement;
    this.state = !!anchorElement.closest('MARK');
  }
}
function saveData(editor){
  editor.save().then((outData) => {
	curr_email = outData;
  });
}
var editor = new EditorJS({
  holder: 'editorjs'
  ,placeholder: 'Start writing your outreach email'
  // ,inlineToolbar: ['link', 'marker', 'bold', 'italic'] // causes save error
  ,tools: {
	header: {class: Header
			 ,config: {placeholder: 'Subject'}},
	inlineCode: {class: InlineCode
				 , shortcut: 'CMD+SHIFT+M'},
	image: textCorrect,
	marker: markerTool
  }
  ,onReady: () => {
	editor.render(initMail).then(() => {
	  editor.save().then((outData) => {
		prev_email = outData;
		curr_email = outData;
	  });
	});
  }
  ,onChange: (api, event) => {
	editor.save().then((outData) => {
	  curr_email = outData;
	  ask_improvement(20000,50);
	});
  }
});

var promptE = new EditorJS({
  holder: 'prompt_block'
  ,placeholder: 'specify the style'
  ,tools: {
	inlineCode: {class: InlineCode,shortcut: 'CMD+SHIFT+M'},
  }
  ,onReady: () => {
	promptE.render(initPrompt).then(() => {
	  promptE.save().then((outData) => {
		curr_prompt = outData;
	  });
	});
  }
  ,onChange: (api, event) => {
	console.log('Now I know that prompt content changed!', event)
	promptE.save().then((outData) => {
	  curr_prompt = outData;
	});
  }
});

var styleE = new EditorJS({
  holder: 'criteria_block'
  ,placeholder: 'specify the style'
  ,tools: {
	inlineCode: {class: InlineCode,shortcut: 'CMD+SHIFT+M'},
  }
  ,onReady: () => {
	styleE.render(initStyle).then(() => {
	  styleE.save().then((outData) => {
		curr_style = outData;
	  });
	});
  }
  ,onChange: (api, event) => {
	console.log('Now I know that style content changed!', event)
	styleE.save().then((outData) => {
	  curr_style = outData;
	});
  }
});

// const saveButton = document.getElementById('save_button');
// const output = document.getElementById('output');
// saveButton.addEventListener('click', () => {
//   editor.save().then( savedData => {
//     output.innerHTML = JSON.stringify(savedData, null, 4);
// 	console.log(savedData);
//   })
// })
function apply_event(){
  $('.apply_button').click(function(){
	var changeD = $.parseJSON($(this).attr('data-button'));
	let text = changeD['text'].replace(/\^/g,"'");
	curr_email.blocks[changeD.block]['data']['text'] = text;
	editor.render(curr_email).then(() => {
	  editor.save().then((outData) => {
		prev_email = outData;
		curr_email = outData;
	  });
	  $('.corrections').text("continue editing the text for corrections.");
	});
  });
}
apply_event();
function call_assistant(prompt,blockD,callbackF){
  let header = {"Authorization":"Bearer "}
  $.ajaxSetup({headers: header});
  $.ajax({
	url: "/correct/call",headers: header
	,contentType: "application/json; charset=utf-8",dataType: 'json'
	,method: "POST",data: JSON.stringify(prompt)
	,success: function(data){
	  $(".inspiration").text('')
	  try {
		data.choices.forEach(b => {
		  // console.log(b['message']);
		  callbackF(b['message']['content'],blockD);
		});
	  }
	  catch(e) {
		// console.log(data['error']['message']);
		callbackF('Error: ' + data['error']['message'],blockD);
	  }
	}
	,failure: function(error){
	  console.log('failure: ',error);
	}
  });
}
function write_correction(text,blockD){
  let corrT = curr_email.blocks[blockD.block]['data']['text'];
  let textS = text.replace(/"/g,"");
  let corrS = "<s>" + corrT + "</s> ---> " + textS;
  let cleanT = text.replace(/'/g, '^').replace(/"/g, '\\\"').replace(/\n/g,"");
  let changeD = '{"block":'+blockD.block+',"text":"'+ cleanT +'"}';
  let buttonS = '<button id="apply" class="apply_button" data-button=\''+changeD+'\'>apply</button>';
  $(".corrections").html(corrS + buttonS);
  apply_event();
}
function write_inspiration(text,blockD){$(".inspiration").text(text);}

function ask_improvement(time_thre,dist_thre){
  $(".corrections").html('<img src="img/loading.gif" />')
  let resp = block_distance(curr_email,prev_email);
  console.log('distance',resp);
  if(resp.text == '' || resp.time < time_thre || resp.dist < dist_thre){
	$(".corrections").html('not enough edit for corrections')
	return ;
  }
  // prev_email = curr_email;
  let promptS = curr_style.blocks[resp.b]['data']['text'] + ': "' + resp.text + '"';
  blockD.block = resp.b;
  promptS = promptS.replace("<br>","").replace(/&nbsp;/g,"");
  promptD['messages'][0]['content'] = promptS;
  call_assistant(promptD,blockD,write_correction);
}

$(".improve_button").click(function(){ask_improvement(30,3);});
$(".call_button").click(function(){
  $(".inspiration").html('<img src="img/loading1.gif" />')
  let promptS = mail2string(curr_prompt);
  promptD['messages'][0]['content'] = promptS;
  call_assistant(promptD,blockD,write_inspiration);
});
