import React, {useState} from 'react'
import {Button,Alert,StyleSheet,Text,View,TextInput,TouchableOpacity,ScrollView,Keyboard} from 'react-native'
import {FlatList, Picker} from 'react-native'

import { Provider } from 'react-redux';
import { createStore, combineReducers } from 'redux';
import { reducer as formReducer } from 'redux-form';
import Icon from 'react-native-vector-icons/FontAwesome';
import { Input, Select } from 'react-native-elements';
import { loadSettings, saveSettings } from '../storage/settingStorage';
import DatePicker from 'react-native-datepicker';

const fieldF = require('../data/patientForm.json');
const fieldL = fieldF['fields'];

function createDate(g){
    return (
	<DatePicker style={{width: 200}} date="2020-06-06"
	mode="date" 
	placeholder="select date"
	format="YYYY-MM-DD"
	minDate="01-01-2016"
	maxDate="01-01-2019"
	confirmBtnText="Confirm"
	cancelBtnText="Cancel"
	onDateChange={(date) => {this.setState({date: date})}}
	    />
    );
}

function createList(listV){
    //const [selectedValue, setSelectedValue] = useState("java");
    return (<Picker style={{ height: 50, width: 150 }} mode="dropdown"
            onValueChange={(itemValue, itemIndex) => setSelectedValue(itemValue)}>
	    {listV.map( (x,i) => {return( <Picker.Item label={x} key={i} value={x}  />)} )}
	    </Picker>
	   )}


function createForm(fieldL){
    var formF = [];
    for(var k in fieldL){
	var g = fieldL[k];
	if(!(g['active'])){continue;}
	if(g['type'] === 'multiple'){var f = createList(g['values']);}
	if(g['type'] === 'date'){var f = createDate(g);}
	else{
	    var f = <TextInput key={k} name={g['key']} placeholder={g['placeholder']} style={styles.textInput} required/>;
	}
	formF.push(f)
    }
    return formF;
}


const rootReducer = combineReducers({form: formReducer,});
const store = createStore(rootReducer);
class App extends React.Component {
    constructor(props) {
	super(props);
	this.state = { name: '' }
	this.handleNameChange = this.handleNameChange.bind(this);
	this.handleSubmit = this.handleSubmit.bind(this);
    }
    handleSubmit() {
	saveSettings(this.state);
    }
    handleNameChange(name) {
	this.setState({ name });
    }
    async componentDidMount() {
	const initialState = await loadSettings();
	this.setState(initialState);
    }
    render() {
	return (
		<Provider store={store}>
		<ScrollView style={styles.container}>
		{ createForm(fieldL) } 
		<TextInput style={styles.textInput} placeholder="Your name" maxLength={20} onBlur={Keyboard.dismiss} value={this.state.name} onChangeText={this.handleNameChange} />

		<Input placeholder='BASIC INPUT' />
		<Input placeholder='INPUT WITH ICON' leftIcon={{ type: 'font-awesome', name: 'chevron-left' }} />
		<Input placeholder='INPUT WITH CUSTOM ICON' leftIcon={<Icon name='user'	size={24} color='black' />}/>
		<Input placeholder="Comment" leftIcon={{ type: 'font-awesome', name: 'comment' }} style={styles} onChangeText={value => this.setState({ comment: value })} />
		<Input placeholder='INPUT WITH ERROR MESSAGE' errorStyle={{ color: 'red' }} errorMessage='ENTER A VALID ERROR HERE' />
		<Input placeholder="Password" secureTextEntry={true} />
		<TouchableOpacity style={styles.saveButton} onPress={this.handleSubmit}	>
		<Text style={styles.saveButtonText}>Save</Text>
		</TouchableOpacity>
		</ScrollView>
		</Provider>
	);
    }
}


const styles = StyleSheet.create({
    inputContainer: {
	paddingTop: 15
    },
    textInput: {
	borderColor: '#CCCCCC',
	borderTopWidth: 1,
	borderBottomWidth: 1,
	height: 50,
	fontSize: 25,
	paddingLeft: 20,
	paddingRight: 20
    },
    saveButton: {
	borderWidth: 1,
	borderColor: '#007BFF',
	backgroundColor: '#007BFF',
	padding: 15,
	margin: 5
    },
    saveButtonText: {
	color: '#FFFFFF',
	fontSize: 20,
	textAlign: 'center'
    }


})

export default App;
