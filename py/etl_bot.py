import os
import sys
sys.path.append("/home/sabeiro/lav/media/script/py/")
import json
import numpy as np
import scipy, scipy.stats
import pandas as pd
import requests
import pylab 

resq = requests.get("http://www.mediaset.it/auditel/ascolti.shtml")
resq.text().encode("utf-8")


