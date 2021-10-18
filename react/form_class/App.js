import React, {useState} from 'react';
import {Button,Image,StyleSheet,TouchableOpacity,View,Container,Content,Platform} from 'react-native';
import {Header,Title,Body,Text} from 'native-base';
//import { Container, Item, Input, Header, Body, Content, Title, Button, Text } from 'native-base';
//import { FormLabel, FormInput, FormValidationMessage } from 'react-native-elements';
import { Provider } from 'react-redux';
import { createStore, combineReducers } from 'redux';
import { reducer as formReducer } from 'redux-form';
import SimpleForm from './Form';
//import t from 'tcomb-form-native';

const rootReducer = combineReducers({form: formReducer,});
const store = createStore(rootReducer);


class App extends React.Component{
    constructor(props){
	super(props);
	this.user = {"id":1,"name":"ciccio","email":"ciccio@pasticcio.it"
		     ,"isSubmited":false
		     ,"picture":{"data":{"url":"./f/user.png"}}};
 	this.state = {isReady: true, count: 0};
 	this.renderInput = this.renderInput.bind(this);
 	this.setUser = this.setUser.bind(this);
	console.log(this.user);
    }
    clickCount = () => {
	this.setState({count: this.state.count + 1})
    }
    setUser = (user_data) => {
	this.user = user_data
    }
    renderInput({ input, label, type, meta: { touched, error, warning } }){
 	var hasError= false;
 	if(error !== undefined){hasError= true;}
 	return( 
 		<Item error= {hasError}>
 		<Input {...input}/>
 		{hasError ? <Text>{error}</Text> : <Text />}
 	    </Item>
 	)
    }
    _handlePressAsync = async () => {
	const result = await promptAsync({ useProxy });
	if (result.type !== "success") {
	    alert("Uh oh, something went wrong");
	    return;
	}
	let accessToken = result.params.access_token;
	let userInfoResponse = await fetch(
	    `https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,picture.type(large)`
	);
	const userInfo = await userInfoResponse.json();
	this.setUser(userInfo);
    };
    postContact = (patientData) => {
	if(this.state.msg!=null){
	    fetch('https://contact-form-db-133.firebaseio.com/contacts.json', {
		method:'POST',headers: {Accept:'application/json','Content-Type':'application/json',},
		body:JSON.stringify(patientData)
	    })
		.then((response) => response.json())
		.then((responseData) => {
		    if(responseData.name !=null ){
			this.refs[nameClear].setNativeProps({text:''});
			this.refs[mobileClear].setNativeProps({text:''});
			this.refs[emailClear].setNativeProps({text:''});
			this.refs[msgClear].setNativeProps({text:''});
			this.setState({name:null,mobile:null,email:null,msg:null,isSubmited:true,})
		    }
		    else{
			Alert.alert(
			    'Oops !',
			    'Something went wrong',[
				{text: 'OK', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},],
			    { cancelable: false })
		    }
		})
		.done();
	}
	else{
	    Alert.alert(
		'Oops !',
		'Press SUBMIT button after entering your message',[
		    {text: 'OK', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},],
		{ cancelable: false })
	}
    };

    handleSubmit = () => {
	const value = this._form.getValue();
	console.log('value: ', value);
    }
    render() {
	const count = 0;
	return (
		<Provider store={store}>
		<Header style={styles.header} >
		<Title style={{flex:3}}>Patient Form</Title>
		{this.user ? (
			<View style={styles.profile}>
			<Image source={require('./f/user.png')} style={styles.image} />
			<Text style={styles.name}>{this.user.name}</Text>
			</View>
		) : (
			<Button disabled={!request} title="Open FB Auth" onPress={_handlePressAsync} />
		)}
	    </Header>
		<Body style={styles.body}>
		<View style={styles.mainForm}>
		<Text style={styles.welcome}>Insert data</Text>
		<SimpleForm />
		</View>
		<View style={styles.container}>
		<TouchableOpacity style={styles.button} onPress={this.clickCount} >
		<Text>Click me</Text>
		</TouchableOpacity>
		<View style={styles.countContainer}>
		<Text> You clicked { this.state.count } times </Text>
		</View>
		</View>
		</Body>
		</Provider>
	);
    }
}

const styles = StyleSheet.create({
    header: {
	flex:1,justifyContent:'center',
	alignItems:'flex-start',
    },
    body: {
	flex:5,flexDirection:'row',
	justifyContent:'center',
	alignItems:'flex-start',
    },
    profile: {
	flex: 1,
	flexDirection: 'row',
	backgroundColor: '#3f51b5',
	// color:'#fff',
	alignItems: 'center',
	justifyContent: 'center',
	marginRight:0,
    },
    name: {
	color: '#fff',
	flex:1, flexDirection: 'row'
    },
    container: {
	flex: 1,
	backgroundColor: '#fff',
	alignItems: 'center',
	justifyContent: 'center',
    },
    mainForm: {
	flex: 3,
	backgroundColor: '#fff',
	alignItems: 'center',
	justifyContent: 'center',
    },
    welcome: {
	fontSize: 20,
	textAlign: 'center',
	margin: 10,
    },
    instructions: {
	textAlign: 'center',
	color: '#333333',
	marginBottom: 5,
    },
    form: {
	textAlign: 'center',
	color: '#333333',
	marginBottom: 5,
    },
    button: {
	alignItems: 'center',
	backgroundColor: '#DDDDDD',
	padding: 10,
	marginBottom: 10
    },
    image: {
	width:30, height:30,
	margin: 10,
	flex:1, flexDirection: 'row'
    },
});

export default App;
