import React, { Component } from 'react';
import { StyleSheet, View, TextInput, TouchableOpacity, Text, SafeAreaView, PermissionsAndroid, Button} from 'react-native';
import {AppRegistry, Linking} from 'react-native';
 
import Constants from "expo-constants";
import QRCode from 'react-native-qrcode-svg';

import * as Permissions from 'expo-permissions';
//import {PERMISSIONS} from 'react-native-permissions';
//import QRCodeScanner from 'react-native-qrcode-scanner';
//import { RNCamera } from 'react-native-camera';


async function checkMultiPermissions() {
  const { status, expires, permissions } = await Permissions.getAsync(
    Permissions.CAMERA,
  );
  if (status !== 'granted') {
    alert('Hey! You have not enabled selected permissions');
  }
}


const requestCameraPermission = async () => {
  try {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.CAMERA,
      {
        title: "Cool Photo App Camera Permission",
        message:
          "Cool Photo App needs access to your camera " +
          "so you can take awesome pictures.",
        buttonNeutral: "Ask Me Later",
        buttonNegative: "Cancel",
        buttonPositive: "OK"
      }
    );
    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      console.log("You can use the camera");
    } else {
      console.log("Camera permission denied");
    }
  } catch (err) {
    console.warn(err);
  }
};


class App extends Component {
  constructor() {
    super();
    this.state = {
      inputValue: '',
      valueForQRCode: '',
    };
  }
  getTextInputValue = () => {
    this.setState({ valueForQRCode: this.state.inputValue });
  };
  render() {
    return (
	    <View style={styles.MainContainer}>
	    <View style={styles.container}>
	    <Text style={styles.item}>Try permissions</Text>
	    <Button title="request permissions" onPress={requestCameraPermission} />
	    </View>
            <QRCode
          value={this.state.valueForQRCode ? this.state.valueForQRCode : 'NA'}
          size={250}
          color="black"
          backgroundColor="white"
        />
        <TextInput
          // Input to get the value to set on QRCode
          style={styles.TextInputStyle}
          onChangeText={text => this.setState({ inputValue: text })}
          underlineColorAndroid="transparent"
          placeholder="Enter text to Generate QR Code"
        />
        <TouchableOpacity
          onPress={this.getTextInputValue}
          activeOpacity={0.7}
          style={styles.button}>
          <Text style={styles.TextStyle}> Generate QR Code </Text>
        </TouchableOpacity>
      </View>
    );
  }
}
export default App;
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    paddingTop: Constants.statusBarHeight,
    backgroundColor: "#ecf0f1",
    padding: 8
  },
  item: {
    margin: 24,
    fontSize: 18,
    fontWeight: "bold",
    textAlign: "center"
  },
  MainContainer: {
    flex: 1,
    margin: 10,
    alignItems: 'center',
    paddingTop: 40,
  },
  TextInputStyle: {
    width: '100%',
    height: 40,
    marginTop: 20,
    borderWidth: 1,
    textAlign: 'center',
  },
  button: {
    width: '100%',
    paddingTop: 8,
    marginTop: 10,
    paddingBottom: 8,
    backgroundColor: '#F44336',
    marginBottom: 20,
  },
  TextStyle: {
    color: '#fff',
    textAlign: 'center',
    fontSize: 18,
  },
});
