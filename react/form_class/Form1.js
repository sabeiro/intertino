import { PropTypes } from 'prop-types';
import {Button,View,TextInput,StyleSheet} from 'react-native';
import {Header,Title,Body,Text} from 'native-base';
import { Field } from 'redux-form';
import RFTextView from './textInput';
import { reduxForm } from 'redux-form';
import React, { Component } from 'react';

const fieldF = require('./patientForm.json');
const fieldL = fieldF['fields'];

const result = {
    "disease":"diabetes"
    ,"result":"high risk patient"
    ,"recommendation":"recommend influenza vaccine"
    ,"info":"influenza vaccine information 2020"
}
const book = {
    "appointment_booking":"appointment booking"
    ,"doctor":"doctor"
}
const storage = {
    "medication":"medication"
    ,"delivery_date":"2020-06-06"
    ,"delivery_driver":"delivery driver"
    ,"delivery_time":"10:00"
    ,"delivery_location":"delivery location"
}

function createForm(fieldL){
    var formF = [];
    for(var k in fieldL){
	var g = fieldL[k];
	if(!(g['active'])){continue;}
	if(g['type'] === 'multiple'){
	    // let d = [];
	    // for(var i in g['values']){
	    // 	d.push({"value":g['values'][i]});
	    // }
	    let d = [{"value":"ciccio"},{"value":"pasticcio"}];
	    console.log(d);
	    var f = <Dropdown key={k} label={g['key']} data={d} style={styles.textInput} required/>;
	}
	else{
	    var f = <TextInput key={k} name={g['key']} placeholder={g['placeholder']} style={styles.textInput} required/>;
	}
	formF.push(f)
    }
    return formF;
}

const PatientFormView = ({ handleSubmit }) => (
	<View>
	{ createForm(fieldL) } 
	<Button title="Submit" onPress={handleSubmit}/>
	<form>
	<span className="formtext"></span>
    	<input type="text" placeholder="Enter Company Name" required  />
        <button>submit</button>
    	</form>
	</View>
); 

PatientFormView.propTypes = { handleSubmit: PropTypes.func.isRequired,};
const FORM = 'simple';
const PatientFormRF = reduxForm({form: FORM,})(PatientFormView);

class PatientForm extends Component {
  handleSubmit = ({ firstName, lastName }) => {
    console.log(`firstname: ${firstName}`);
    console.log(`lastName: ${lastName}`);
  }
  render() {
    return <PatientFormRF onSubmit={this.handleSubmit} />;
  }
}


const styles = StyleSheet.create({
    textInput: {
	borderColor: '#CCCCCC',
	borderTopWidth: 1,
	borderBottomWidth: 1,
	height: 50,
	fontSize: 25,
	paddingLeft: 20,
	paddingRight: 20
    }
});

export default PatientForm;
