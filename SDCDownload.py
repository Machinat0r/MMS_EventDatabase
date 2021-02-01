# -*- coding: utf-8 -*-
"""
Created on Wed Jan 27 18:03:42 2021

@author: fwd
"""

import requests
import time
import re
import os

def downloadFile(url,path):
    start = time.time()
    size = 0
    #proxy = 'hk-aga-o-1.v2fast.win'
    #proxy_support = {'http':'http://'+proxy,'https':'https://'+proxy,}
    response = requests.get(url,stream = True) # proxies = proxy_support
    chunk_size = 1024#每次块大小为1024
    content_size = int(response.headers['content-length'])
    if os.path.exists(path) and os.path.getsize(path) == content_size:
        print('该文件已下载')
    else:
        print("文件大小："+str(round(float(content_size/chunk_size/1024),4))+"[MB]")
        with open(path,'wb') as FileTemp:
            for data in response.iter_content(chunk_size=chunk_size):#每次只获取一个chunk_size大小
                FileTemp.write(data)#每次只写入data大小
                size = len(data)+size
                print('\r'+"已经下载："+" 【"+str(round(size/chunk_size/1024,2))+"MB】"\
                      +"【"+str(round(float(size/content_size)*100,2))+"%"+"】",end="")
        end = time.time()
        print('\r'+"总耗时:"+str(end-start)+"s"+"平均速度："+str(content_size/chunk_size/1024/(end-start))+"M/s")



if __name__ == '__main__':
    Date = '2019-04-29/2019-04-30'.split('/')
    inst_ids = '&instrument_ids=fgm'  #仪器
    drm = '&data_rate_mode=srvy,brst'   #模式
    desc = '&descriptors='   #描述符
    sc_ids = '&sc_ids='    

    for ic in range(1,5):  #卫星编号
        sc_ids += 'mms'+str(ic)+','
    sc_ids = sc_ids[:-1]
        
    para = [inst_ids,drm,desc,sc_ids]
    url = 'https://lasp.colorado.edu/mms/sdc/public/files/api/v1/file_names/science?start_date='\
        + Date[0] + '&end_date=' + Date[1]
    
    for i in para:
        if i.split('=')[1] != '':
            url += i
            
    headers = {'Proxy-Connection': 'keep-alive'}
    SourceFile = requests.get(url,headers=headers).text
    expr = re.compile(r'mms[1234]_(.+?)\.cdf')
    FileNames = re.finditer(expr,str(SourceFile))
    #print(FileNames)
    
    FileUrl = 'https://lasp.colorado.edu/mms/sdc/public/files/api/v1/download/science?file='
    #迭代器在使用之前无法知道个数，不知道有没有更好的办法获取总数
    FileNum = len(re.findall(expr,SourceFile))    
    flag = 0
    path = "C:/Users/fwd/Desktop/python exercise/MMS/"
    for File in FileNames:
        flag += 1
        FileName = str(File.group())
        print("开始下载文件"+str(flag)+'/'+str(FileNum))
        downloadFile(FileUrl+FileName,path+FileName)

