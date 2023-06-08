//--------------------------chain-promises-----------------------------
var message = "";
promise1 = new Promise((resolve, reject) => {
    setTimeout(() => {
        message += "my";
        resolve(message);
    }, 2000)
})
promise2 = new Promise((resolve, reject) => {
    setTimeout(() => {
        message += " first";
        resolve(message);
    }, 2000)
})
promise3 = new Promise((resolve, reject) => {
    setTimeout(() => {
        message += " promise";
        resolve(message);
    }, 2000)
})
var printResult = (results) => {console.log("Results = ", results, "message = ", message)}
function main() {
    // See the order of promises. Final result will be according to it
    Promise.all([promise1, promise2, promise3]).then(printResult);
    Promise.all([promise2, promise1, promise3]).then(printResult);
    Promise.all([promise3, promise2, promise1]).then(printResult);
    console.log("\"\"" + message);
}
main();
//----------------------------chain-promises-2-----------------------------
const request = require('request-promise');
const urls = ["http://www.google.com", "http://www.example.com"];
const promises = urls.map(url => request(url));
Promise.all(promises).then((data) => {
    // data = [promise1,promise2]
});
//---------------------------async-await-----------------------------------
const list = [1, 2, 3, 4, 5] //...an array filled with values
const functionWithPromise = item => { //a function that returns a promise
    return Promise.resolve('ok')
}
const anAsyncFunction = async item => {
    return functionWithPromise(item)
}
const getData = async () => {
    return Promise.all(list.map(item => anAsyncFunction(item)))
}
getData().then(data => {
    console.log(data)
})

//--------------------------timeout-sequential---------------------------------
for (var i = 0; i < 5; i++) {
    (function(i) {
	setTimeout(function () {
	    console.log(i);
	}, i);
    })(i);
}
//-------------------------callback-on-promise------------------------------------
const http = require('http');
function getPromise() {
    return new Promise((resolve, reject) => {
	http.get('http://www.usefulangle.com/api?api_key=554545', (response) => {
	    let chunks_of_data = [];
	    response.on('data', (fragments) => {
		chunks_of_data.push(fragments);
	    });
	    response.on('end', () => {
		let response_body = Buffer.concat(chunks_of_data);
		resolve(response_body.toString());
	    });
	    response.on('error', (error) => {
		reject(error);
	    });
	});
    });
}
async function makeSynchronousRequest(request) {
    try {
	let http_promise = getPromise();
	let response_body = await http_promise;
	console.log(response_body);
    }
    catch(error) {
	console.log(error);
    }
}
console.log(1);
(async function () {
    await makeSynchronousRequest();
    console.log(2);
})();
console.log(3);
//------------------------------other-await-syntax---------------------------------
const doSomethingAsync = () => {
    return new Promise(resolve => {
	setTimeout(() => resolve('I did something'), 3000)
    })
}
const doSomething = async () => {
    console.log(await doSomethingAsync())
}
const aFunction = async () => {
    return Promise.resolve('test')
}
aFunction().then(alert) // This will alert 'test'
//-----------------pipe promises and alternative await async wrinting--------------
const getFirstUserData = () => {
    return fetch('/users.json') // get users list
	.then(response => response.json()) // parse JSON
	.then(users => users[0]) // pick first user
	.then(user => fetch(`/users/${user.name}`)) // get user data
	.then(userResponse => userResponse.json()) // parse JSON
}
getFirstUserData()
const getFirstUserData = async () => {
    const response = await fetch('/users.json') // get users list
    const users = await response.json() // parse JSON
    const user = users[0] // pick first user
    const userResponse = await fetch(`/users/${user.name}`) // get user data
    const userData = await userResponse.json() // parse JSON
    return userData
}
getFirstUserData()
//-------------------------retry------------------------------
function request(url) {
    return new Promise((resolve, reject) => {
	setTimeout(() => {
	    reject(`Network error when trying to reach ${url}`);
	}, 500);
    });
}
function requestWithRetry(url, retryCount, currentTries = 1) {
    return new Promise((resolve, reject) => {
	if (currentTries <= retryCount) {
	    const timeout = (Math.pow(2, currentTries) - 1) * 100;
	    request(url)
		.then(resolve)
		.catch((error) => {
		    setTimeout(() => {
			console.log('Error: ', error);
			console.log(`Waiting ${timeout} ms`);
			requestWithRetry(url, retryCount, currentTries + 1);
		    }, timeout);
		});
	} else {
	    console.log('No retries left, giving up.');
	    reject('No retries left, giving up.');
	}
    });
}
requestWithRetry('http://localhost:3000')
    .then((res) => {
	console.log(res)
    })
    .catch(err => {
	console.error(err)
    });
//-----------------------------retry-async---------------------------------
//https://blog.risingstack.com/mastering-async-await-in-nodejs/#whatareasyncfunctionsinnode
function wait (timeout) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve()
    }, timeout);
  });
}
async function requestWithRetry (url) {
  const MAX_RETRIES = 10;
  for (let i = 0; i <= MAX_RETRIES; i++) {
    try {
      return await request(url);
    } catch (err) {
      const timeout = Math.pow(2, i);
      console.log('Waiting', timeout, 'ms');
      await wait(timeout);
      console.log('Retrying', err.message, i);
    }
  }
}
