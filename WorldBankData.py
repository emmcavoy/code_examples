#Author: emmcavoy
#Last modified 2/16/22
#This script downloads data from the World Bank and transforms the data into a single CSV file for longitudinal analysis with country-year as unit of analysis 

#Required libraries
#Script created in Python 3.9.7
import pandas as pd
import undetected_chromedriver as uc
import os
import sys
import zipfile
import time

#All the data to download (links to CSV files)
websites=['https://api.worldbank.org/v2/en/indicator/NY.GDP.PCAP.PP.CD?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SI.POV.GINI?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SL.TLF.TOTL.IN?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SL.UEM.TOTL.ZS?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/EG.ELC.ACCS.ZS?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/FI.RES.TOTL.CD?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/FP.CPI.TOTL.ZG?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SL.TLF.TOTL.FE.ZS?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SP.DYN.LE00.MA.IN?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SE.ADT.LITR.MA.ZS?downloadformat=csv',
          'https://api.worldbank.org/v2/en/indicator/SP.DYN.CBRT.IN?downloadformat=csv']

#Download files from World Bank
driver=uc.Chrome()
for website in websites:
    driver.get(website)
#Arbitrary time to space downloads    
time.sleep(10)
driver.quit()

#Creates folder in working directory to store CSV files if not already created
if not os.path.exists('csvs'):
  os.mkdir('csvs')

#Unzips CSV files from download location
download_loc='C:/Users/emmcavoy/Downloads'
for file in os.listdir(download_loc):
    if file.endswith('.zip'):
        with zipfile.ZipFile(download_loc+file) as z:
            z.extractall('csvs')

#Transforms data into county year unit of analysis for 2000-2019
i=0
for filename in os.listdir('csvs'):
    result=pd.DataFrame()
    #Reads the CSV files with data (ignores metadata files)
    if 'Metadata' not in filename:
        df=pd.read_csv('csvs/'+filename,skiprows=4,low_memory=False)
        #transform from wide to long format
        temp=pd.melt(df,['Country Name','Country Code'],map(str,list(range(2000,2020))))
        temp.rename(columns={'variable':'year','value':df['Indicator Name'][0]},inplace=True)
        #temp stores all the data for only one indicator (variable) at a time
        #final is the dataframe that stores all the indicators
        #Checks if first iteration
        if i==0:
            final=temp.copy()
        else:
            #Adds new indicator column to final based on country-year
            final=pd.merge(final,temp,'left',['Country Name','Country Code','year'])
        i+=1

#Save final file            
final.to_csv('worldbank_countyyear_2000-2019.csv',index=False)
