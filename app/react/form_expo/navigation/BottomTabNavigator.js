import { Image, Platform, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import * as React from 'react';

import TabBarIcon from '../components/TabBarIcon';
import HomeScreen from '../screens/HomeScreen';
import LinksScreen from '../screens/LinksScreen';
import FormScreen from '../screens/FormScreen';
import ScanScreen from '../screens/ScanScreen';

const BottomTab = createBottomTabNavigator();
const INITIAL_ROUTE_NAME = 'Home';

export default function BottomTabNavigator({ navigation, route }) {
    // Set the header title on the parent stack navigator depending on the
    // currently active tab. Learn more in the documentation:
    // https://reactnavigation.org/docs/en/screen-options-resolution.html
    navigation.setOptions({ headerTitle: getHeaderTitle(route) });

    return (
	    <BottomTab.Navigator initialRouteName={INITIAL_ROUTE_NAME}>
	    <BottomTab.Screen name="Home" component={HomeScreen}
	options={{title: 'intro', tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="md-home" />,}} />
	    <BottomTab.Screen name="Form" component={FormScreen} options={{title: 'form',tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="md-add" />,}}/>
	    <BottomTab.Screen name="Scan" component={ScanScreen} options={{title: 'scan',tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="md-qr-scanner" />,}}/>
	    <BottomTab.Screen name="Links" component={LinksScreen} options={{title: 'Resources',tabBarIcon: ({ focused }) => <TabBarIcon focused={focused} name="md-book" />,}}/>
	    </BottomTab.Navigator>
    );
}

function getHeaderTitle(route) {
    const routeName = route.state?.routes[route.state.index]?.name ?? INITIAL_ROUTE_NAME;
    switch (routeName) {
    case 'Home':
	return 'How to get started';
    case 'Links':
	return 'Links to learn more';
    }
}
