#%pylab inline
import os
<<<<<<< HEAD
import gzip
import sys
=======
>>>>>>> f9f50ee839761edf34147f3b7185aae925f6ddd6
import numpy as np
import pandas as pd
from scipy.misc import imread
from sklearn.metrics import accuracy_score
import six.moves.cPickle as pickle
<<<<<<< HEAD
import timeit
=======
import gzip
import sys
import timeit
import numpy
>>>>>>> f9f50ee839761edf34147f3b7185aae925f6ddd6
import theano
import theano.tensor as T
from keras.models import Sequential
from keras.layers import Dense
from scipy.misc import imread
from sklearn.metrics import accuracy_score
import tensorflow as tf
import keras
from keras.models import Sequential
import pylab

#loading the MNIST dataset from keras
<<<<<<< HEAD
seed = 128
rng = np.random.RandomState(seed)

# with gzip.open(os.environ['LAV_DIR']+"/log/mnist.pkl.gz", 'rb') as f:
#     try:
#         train_set, valid_set, test_set = pickle.load(f, encoding='latin1')
#     except:
#         train_set, valid_set, test_set = pickle.load(f)


from keras.datasets import mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
#reshaping the x_train, y_train, x_test and y_test to conform to MLP input and output dimensions
x_train = np.reshape(x_train,(x_train.shape[0],-1))/255.
x_test = np.reshape(x_test,(x_test.shape[0],-1))/255.
y_train = pd.get_dummies(y_train)
y_test = pd.get_dummies(y_test)
#performing one-hot encoding on target variables for train and test
y_train = np.array(y_train)
y_test = np.array(y_test)
#defining model with one input layer[784 neurons], 1 hidden layer[784 neurons] with dropout rate 0.4 and 1 output layer [10 #neurons]
model = Sequential()
model.add(Dense(784,input_dim=784,activation='relu'))
#model.add(Dense(output_dim=50,input_dim=784,activation='relu'))
keras.layers.core.Dropout(rate=0.4)
model.add(Dense(10,input_dim=784,activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer="adam", metrics=['accuracy'])
# fitting model and performing validation
model.fit(x_train,y_train,epochs=5,batch_size=128,validation_data=(x_test,y_test))

pred = model.predict_classes(x_test)

imgN = 24
img = x_test[imgN]
img = np.reshape(img,(np.sqrt(img.shape[0]),np.sqrt(img.shape[0])))*255
print "Prediction is: ", pred[imgN]
=======
from keras.datasets import mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
#reshaping the x_train, y_train, x_test and y_test to conform to MLP input and output dimensions
x_train=np.reshape(x_train,(x_train.shape[0],-1))/255
x_test=np.reshape(x_test,(x_test.shape[0],-1))/255
y_train=pd.get_dummies(y_train)
y_test=pd.get_dummies(y_test)
#performing one-hot encoding on target variables for train and test
y_train=np.array(y_train)
y_test=np.array(y_test)
#defining model with one input layer[784 neurons], 1 hidden layer[784 neurons] with dropout rate 0.4 and 1 output layer [10 #neurons]

pylab.imshow(x_train, cmap='gray')
pylab.axis('off')
pylab.show()


model=Sequential()

model.add(Dense(784, input_dim=784, activation='relu'))
keras.layers.core.Dropout(rate=0.4)
model.add(Dense(10,input_dim=784,activation='softmax'))

# compiling model using adam optimiser and accuracy as metric
model.compile(loss='categorical_crossentropy', optimizer="adam", metrics=['accuracy'])
# fitting model and performing validation

model.fit(x_train,y_train,epochs=50,batch_size=128,validation_data=(x_test,y_test))













seed = 128
rng = np.random.RandomState(seed)

root_dir = os.path.abspath('../..')
data_dir = os.path.join(root_dir, 'data')
sub_dir = os.path.join(root_dir, 'sub')
os.path.exists(root_dir)
os.path.exists(data_dir)
os.path.exists(sub_dir)

train = pd.read_csv(os.path.join(data_dir, 'Train', 'train.csv'))
test = pd.read_csv(os.path.join(data_dir, 'Test.csv'))

sample_submission = pd.read_csv(os.path.join(data_dir, 'Sample_Submission.csv'))

train.head()


with gzip.open(os.environ['LAV_DIR']+"/log/mnist.pkl.gz", 'rb') as f:
    try:
        train_set, valid_set, test_set = pickle.load(f, encoding='latin1')
    except:
        train_set, valid_set, test_set = pickle.load(f)

# check for existence
os.path.exists(root_dir)
os.path.exists(data_dir)
train = pd.read_csv(os.path.join(data_dir, 'Train', 'train.csv'))
test = pd.read_csv(os.path.join(data_dir, 'Test.csv'))

sample_submission = pd.read_csv(os.path.join(data_dir, 'Sample_Submission.csv'))
img_name = rng.choice(train.filename)
filepath = os.path.join(data_dir, 'Train', 'Images', 'train', img_name)

img = imread(filepath, flatten=True)

>>>>>>> f9f50ee839761edf34147f3b7185aae925f6ddd6
pylab.imshow(img, cmap='gray')
pylab.axis('off')
pylab.show()


<<<<<<< HEAD
=======
temp = []
for img_name in train.filename:
    image_path = os.path.join(data_dir, 'Train', 'Images', 'train', img_name)
    img = imread(image_path, flatten=True)
    img = img.astype('float32')
    temp.append(img)

train_x = np.stack(temp)

temp = []
for img_name in test.filename:
    image_path = os.path.join(data_dir, 'Train', 'Images', 'test', img_name)
    img = imread(image_path, flatten=True)
    img = img.astype('float32')
    temp.append(img)

test_x = np.stack(temp)

split_size = int(train_x.shape[0]*0.7)

train_x, val_x = train_x[:split_size], train_x[split_size:]
train_y, val_y = train.label.values[:split_size], train.label.values[split_size:]



>>>>>>> f9f50ee839761edf34147f3b7185aae925f6ddd6





