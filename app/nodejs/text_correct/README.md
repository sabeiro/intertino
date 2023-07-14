# text corrector

This app is an automated assistant to help writing outreach sales emails. 

![cover_corrector](views/img/cover_corrector.png "text corrector")
_text corrector overview_

## usage

The user starts editing the draft in the left box, the draft is composed in different sections:

* subject
* greeting
* presentation
* value proposition
* personalization
* goodbye
* signature

![block_editor](views/img/block_editor.png "block editor")
_the editor block composed in sections_

Every time a change is made an algo evaluates the distance from the previous version is computed. The current algo is a mixture of Levenshtein and time difference. 
If the change is consistent enough the current text is appended to a prompt for the language model which can be edited in this section:

![block_criteria](views/img/block_criteria.png "block criteria")
_the criteria block with editable prompts_

The resquest is sent to the backend that appends the authentification and sends the request to the language model. Within few seconds the response is formated and displayed in the correction block:

![block_correction](views/img/block_correction.png "block correction")
_the correction block with suggestions_

The correction block has an apply button that validates the correction and apply the change.

Alternatively there is an instruction section with editable prompts

![block_instruction](views/img/block_instruction.png "block instruction")
_the instruction block with editable prompts_

That would send a request to the language model to generate the email following the instructions

![block_generated](views/img/block_generated.png "block generated")
_the generated block with suggestions_

## technical implementation

The app is mainly written in `nodejs` using `express` and `ejs`. The main functions are written in `javascript` and executes on the frontend.

![front_back](views/img/front_back.svg "front back")
_front- and back- end implementation_

The implementation is as following

![node_calls](views/img/node_call.svg "node calls")
_structure of the calls_

## deployment

Create an `.env` file with:
```
export OPENAI_KEY=...
```
run

```
npm install
npm start
```

or

```
cd build/
docker-compose up -d
```

The app is then available at:

```
localhost:3000/correct
```
