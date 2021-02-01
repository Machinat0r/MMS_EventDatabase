clear;
clc

Date = '2019-01-01/2020-01-30';
splitDate = regexp(Date,'/','split');
% url = ['https://cdaweb.gsfc.nasa.gov/pub/data/mms/mms1/fgm/srvy/l2/',splitDate{1},'/',splitDate{2},'/'];
instrument_ids = 'fgm'; %仪器（可选）
data_rate_modes = 'srvy'; %模式（可选）
descriptors = ''; %描述符（可选,注意，如ins_ids中某仪器无该描述符，则不会下载该仪器的数据）
sc_ids = '';
for ic = 1:4    %卫星编号（可选）
    sc_ids = ['mms',num2str(ic),',',sc_ids];
end
if isempty(instrument_ids) == 0
    instrument_ids = ['&instrument_ids=',instrument_ids];
end
if isempty(data_rate_modes) == 0
    data_rate_modes = ['&data_rate_modes=',data_rate_modes];
end
if isempty(descriptors) == 0
    descriptors = ['&descriptors=',descriptors];
end
sc_ids=['&sc_ids=',sc_ids(1:end-1)];
url = ['https://lasp.colorado.edu/mms/sdc/public/files/api/v1/file_names/science?start_date=', ...
    splitDate{1},'&end_date=',splitDate{2},sc_ids,instrument_ids,data_rate_modes,descriptors];

sourcefile = webread(url);

% expression = '<a.+?href=\"(.+?)\">(.+?)</a>'; %识别网页中的链接
expression = 'mms[1234]_(.+?)\.cdf'; %识别cdf文件名
filenames = regexp(sourcefile,expression,'match');
filenames = unique(filenames);
% celldisp(filenames)

output_dir = ['D:\MMS\',splitDate{1},'To',splitDate{2},'\'];
if isfolder(output_dir) == 0
    mkdir(output_dir);
end
h = waitbar(0,'开始下载');
i = 1;
while i <= length(filenames)
    %检查文件是否已下载过（只能检查断点续传，即未改变下载参数情况下使用该程序所下过的，否则可能会缺漏）     
    if i < length(filenames)
        while isfile([output_dir,filenames{i+1}]) == 1 
            i = i + 1;
            s1 = ['文件夹中已有文件:',num2str(i),'/',num2str(length(filenames))];
            waitbar(i/length(filenames),h,s1);
        end
    end
    
    url_file = ['https://lasp.colorado.edu/mms/sdc/public/files/api/v1/download/science?', ...
        'file=',filenames{i}];
    output_filename = [output_dir,filenames{i}];   
    
    %网站接口需挂vpn下载，如果matlab下载速度过慢则需先挂vpn再打开matlab  
    options = weboptions('Timeout',10);    
    tic 
    websave(output_filename,url_file,options) ;
    TimeInterval = toc;     
    Dir = dir(output_dir); 
    FileIndex = find(strcmp({Dir.name},filenames{i}));
    SizeOfFile = Dir(FileIndex).bytes;
    AverageSpeed = SizeOfFile/(TimeInterval*1024*1024);
    
    %显示进度条
    s2 = ['已下载文件数: ',num2str(i),'/',num2str(length(filenames)), ...
        char(13,10)','最近文件下载速度:',num2str(AverageSpeed),'M/s'];
    waitbar(i/length(filenames),h,s2);   
    i = i+1;
end

if isempty(filenames)
    waitbar(0,h,'无可下载项');
else
    waitbar(1,h,'下载完毕ヽ(✿ﾟ▽ﾟ)ノ');
end
pause(3)
close(h)