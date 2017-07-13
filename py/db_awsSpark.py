from pyspark.sql.types import *
from pyspark.sql.functions import udf,col,explode,struct
from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession
import pyspark.sql.functions as func

conf = SparkConf().setAppName('ga_classifier')\
                      .set("spark.driver.memory",'9g') \
                      .set('spark.executor.cores', '4')\
                      .set("spark.executor.memory", '14g') 

sc   = SparkContext(conf=conf)
spark = SparkSession.builder.getOrCreate()

def table(df, col_name, counter_colname, show=True,n=5000):
    df_ret = df\
                .select(col(col_name))\
                .groupby(col(col_name))\
                .agg(func.count(col_name).alias(counter_colname))

    tot = df_ret.select(func.sum(counter_colname)).rdd.flatMap(lambda x: x).collect()[0]
    df_ret.withColumn('PERC', udf(lambda x: x/tot)(counter_colname))
    return df_ret.show(n=n) if show else df_ret

sum_count = udf(lambda row: sum([1 if x != 0 else 0 for x in row]), IntegerType())

bk_cat_file = 's3n://mediaset-mktg/bk_prediction/bk_categories.csv'
bk_cat = spark.read.option('header','true').csv(bk_cat_file)
bk_cat_df = bk_cat\
                .withColumn('num_lev', udf(lambda x: len(x.split('/')))('path'))\
                .filter(col('num_lev')>1)\
                .filter( (~col('path').like('Log%')) & (~col('path').like('Exaudi%'))  )\
                .withColumn('snd_lev', udf(lambda x:  x.split('/')[1] if len(x.split('/'))>1 else x.split('/')[0])('path'))\
                .withColumn('fst_lev', udf(lambda x:  x.split('/')[0])('path'))\
                .filter( ~ (col('snd_lev').isin('Geografici','Eta', 'Sesso')))\
                .filter( ~ ((col('num_lev') == 2) & (col('path').like('Consumo Media%')) ) )\
                .filter( ~ ((col('num_lev') == 1) & (col('path').like('Hobby e Interessi'))) ) \
                .filter( ~ ((col('num_lev') == 3) & (col('path').like('Consumo Media/Internet%') )))\
                .sort(col('fst_lev'))\
                .select('id', 'path','name', 'fst_lev','snd_lev', 'num_lev', 'reach')

bk_cat_OK = [x for x in bk_cat_df.select('id').rdd.flatMap(lambda x: x).collect()]
bk_dataset_file = 's3n://dl-bluekai-prod/dl_rti/dl_bk_user_synthesis_ls/date=20170430'
complete_dataset = spark.read.parquet(bk_dataset_file)
complete_dataset = complete_dataset\
    .withColumn('gg_card', udf(lambda x: x[0])('multi_id_index'))\
    .withColumn('bk_card', udf(lambda x: x[1])('multi_id_index')) \
    .filter( (col('bk_card') <= 5) & (col('gg_card')  == 1) ) \
    .filter( (col('multi_g_index') == 1) & (col('multi_a_index') == 1))

complete_dataset = complete_dataset.cache()
bk_cat_dataset = complete_dataset\
                    .select('gigya_id', 'gender', 'age_range',explode('bluekai_cat_array').alias('bk_cats'))\
                    .select('gigya_id', 'gender', 'age_range', 'bk_cats.*')\
                    .groupby('gigya_id','gender', 'age_range')\
                    .pivot('cat')\
                    .agg(func.first('wtsn'))\
                    .na.fill(0)

cols = ['gigya_id', 'gender', 'age_range']
cols.extend([c for c in bk_cat_dataset.columns if c in bk_cat_OK])

bk_cat_dataset = bk_cat_dataset\
                    .select(cols)
