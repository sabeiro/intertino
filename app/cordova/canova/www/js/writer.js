var root;
function getById(id) {
    return document.querySelector(id);
}
function onError(e) {
    getById("#content").innerHTML = "<h2>Error</h2>"+e.toString();
}
function metadataFile(m) {
    logit("File was last modified "+m.modificationTime+"<p/>");    
}
function doMetadataFile(e) {
    fileSystem.root.getFile("text.txt", {create:true}, function(f) {
        f.getMetadata(metadataFile,onError);
    }, onError);
}
function doDeleteFile(e) {
    fileSystem.root.getFile("text.txt", {create:true}, function(f) {
        f.remove(function() {
            logit("File removed<p/>");
        });
    }, onError);
}
function readFile(){
    reader = new FileReader();
    reader.onloadend = function(e) {
	console.log("go to end");
	logit("<pre>" + e.target.result + "</pre><p/>");
    }
    reader.readAsText(f);
}
function doReadFile(e) {
    alert('ciccia');
    fileSystem.root.getFile("text.txt", {create:true}, readFile, onError);
}
function appendFile(f){
    f.createWriter(function(writerOb) {
        writerOb.onwrite=function() {
	    logit("Done writing to file.<p/>");
        }
        //go to the end of the file...
        writerOb.seek(writerOb.length);
        writerOb.write("Test at "+new Date().toString() + "\n");
    })
}
function doAppendFile(e) {
    alert("ciccia");
    fileSystem.root.getFile("text.txt", {create:true}, appendFile, onError);
}
function gotFiles(entries) {
    var s = "";
    for(var i=0,len=entries.length; i<len; i++) {
        //entry objects include: isFile, isDirectory, name, fullPath
        s+= entries[i].fullPath;
        if (entries[i].isFile) {
            s += " [F]";
        }
        else {
            s += " [D]";
        }
        s += "<br/>";
    }
    s+="<p/>";
    logit(s);
}
function doDirectoryListing(e) {
    //get a directory reader from our FS
    var dirReader = fileSystem.root.createReader();
    dirReader.readEntries(gotFiles,onError);        
}
function onFSSuccess(fs) {
    fileSystem = fs;
    getById("#dirListingButton").addEventListener("touchstart",doDirectoryListing);            
    getById("#addFileButton").addEventListener("touchstart",doAppendFile);            
    getById("#readFileButton").addEventListener("touchstart",doReadFile);            
    getById("#metadataFileButton").addEventListener("touchstart",doMetadataFile);            
    getById("#deleteFileButton").addEventListener("touchstart",doDeleteFile);            
    logit( "Got the file system: "+fileSystem.name +"<br/>" +
                                    "root entry name is "+fileSystem.root.name + "<p/>")    
    doDirectoryListing();
} 
function onDeviceReady() {
    //request the persistent file system
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onFSSuccess, onError);
}
function init() {
    document.addEventListener("deviceready", onDeviceReady, true);
}


init();












function onInitFs(fs) {
    var fileURL = "cdvfile://localhost/persistant/file.png";
    var fileTransfer = new FileTransfer();
    var uri = encodeURI("http://upload.wikimedia.org/wikipedia/commons/6/64/Gnu_meditate_levitate.png");
    fileTransfer.download(
            uri,
            fileURL,
            function(entry) {
                console.log("download complete: " + entry.fullPath);
            },
            function(error) {
                console.log("download error source " + error.source);
                console.log("download error target " + error.target);
                console.log("upload error code" + error.code);
            },
            false,
            {
                headers: {
                    "Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="
                }
            }
    );
}

function winRead(file) {
    var reader = new FileReader();
    reader.onloadend = function(evt) {
        console.log("read success");
        console.log(evt.target.result);
    };
    reader.readAsDataURL(file);
    //reader.readAsText(file);
};
function winWrite(writer) {
    writer.onwrite = function(evt) {
        console.log("write success");
    };
    writer.seek(writer.length);
    writer.write("appended text");
};
var fail = function(evt) {
    console.log(error.code);
};

//entry.file(win, fail);

var fail = function(evt) {
    console.log(error.code);
};

//entry.createWriter(win, fail);



function gotFS(fileSystem) {
    fileSystem.root.getFile("readme.txt", null, gotFileEntry, fail);
}

function gotFileEntry(fileEntry){
    fileEntry.file(gotFile, fail);
}

function gotFile(file){
    readDataUrl(file);
    readAsText(file);
}

function readDataUrl(file){
    var reader = new FileReader();
    reader.onloadend = function(evt) {
        console.log("Read as data URL");
        console.log(evt.target.result);
    };
    reader.readAsDataURL(file);
}

function readAsText(file) {
    var reader = new FileReader();
    reader.onloadend = function(evt) {
        console.log("Read as text");
        console.log(evt.target.result);
    };
    //reader.readAsText(file);
}

var text = readAsText('readme.txt');
//console.log(text);




var getValue = function(id){
    return document.querySelector('#'+id).value;
};

var saveCookie = function(){
    document.cookie = '';
    document.cookie += 'a='+getValue('value0');
    document.cookie += 'b='+getValue('value1');
    document.cookie += 'c='+getValue('value2');
};
function getCookie(c_name){
    var i,x,y,ARRcookies=document.cookie.split(";");
    for (i=0;i<ARRcookies.length;i++){
	x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
	y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
	x=x.replace(/^\s+|\s+$/g,"");
	if (x==c_name){
	    return unescape(y);
	}
    }
}
function setCookie(c_name,value,exdays){
    var exdate=new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
    document.cookie=c_name + "=" + c_value;
}
function writeCookie(){
    $.cookie.json = true;
    $.cookie('selettore',data,{expires:1000,path:'/'});
    alert($.cookie('selettore'));
}
function checkCookie(){
    var username=getCookie("username");
    if (username!=null && username!=""){
	alert("Welcome again " + username);
    }
    else {
	username=prompt("Please enter your name:","");
	if (username!=null && username!="") {
	    setCookie("username",username,365);
	}
    }
}
function startRead() {  
    // obtain input element through DOM 
    var file = document.getElementById('file').files[0];
    if(file){
	getAsText(file);
    }
}
function getAsText(readFile) {
    var reader = new FileReader();
    // Read file into memory as UTF-16      
    reader.readAsText(readFile, "UTF-16");
    // Handle progress, success, and errors
    //  reader.onprogress = updateProgress;
    reader.onload = loaded;
    reader.onerror = errorHandler;
}
function updateProgress(evt) {
    if (evt.lengthComputable) {
	// evt.loaded and evt.total are ProgressEvent properties
	var loaded = (evt.loaded / evt.total);
	if (loaded < 1) {
	    // Increase the prog bar length
	    // style.width = (loaded * 200) + "px";
	}
    }
}
function loaded(evt) {  
    // Obtain the read file data    
    var fileString = evt.target.result;
    // Handle UTF-16 file dump
    if(utils.regexp.isChinese(fileString)) {
	//Chinese Characters + Name validation
    }
    else {
	// run other charset test
    }
    // xhr.send(fileString)     
}
function errorHandler(evt) {
    if(evt.target.error.name == "NotReadableError") {
	// The file could not be read
    }
}


function readSingleFile(evt) {
    var oFile = evt.target.files[0]; 
    if(oFile){
	var r = new FileReader();
	r.onload = function(e) { 
	    var contents = e.target.result;
	    alert( "Got the file.n" 
		   +"name: " + oFile.name + "n"
		   +"type: " + oFile.type + "n"
		   +"size: " + oFile.size + " bytesn"
		   + "starts with: " + contents.substr(1, contents.indexOf("n"))
		 );  
	}
	r.readAsText(oFile);
    } else { 
	alert("Failed to load file");
    }
}
function handleFileSelect()
{               
    if (window.File && window.FileReader && window.FileList && window.Blob) {

    } else {
        alert('The File APIs are not fully supported in this browser.');
        return;
    }   

    input = document.getElementById('fileinput');
    if (!input) {
        alert("Um, couldn't find the fileinput element.");
    }
    else if (!input.files) {
        alert("This browser doesn't seem to support the `files` property of file inputs.");
    }
    else if (!input.files[0]) {
        alert("Please select a file before clicking 'Load'");               
    }
    else {
        file = input.files[0];
        fr = new FileReader();
        fr.onload = receivedText;
        fr.readAsText(file);
    }
}

function receivedText() {           
    //result = fr.result;
    document.getElementById('editor').appendChild(document.createTextNode(fr.result))
}           

function Scrittore(){


}

