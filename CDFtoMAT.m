function CDFtoMAT(runname,keepvars)
%Cut each slice from ~73MB to ~6MB and a format that can be read in chunks

if(nargin<1 || isempty(runname))
    runname='Victoir_Veibell_092716_1'; %Default to ux
end
if(nargin<2)
    keepvars={'x','y','z','ux','bz'}; 
end



    %Find all CDF files for each timestep and read them in to one array
    basedir=sprintf('/home/victoir/Work/Differences/data/%s/GM_CDF/',runname);
    files=dir(sprintf('%s/*cdf',basedir));
    
    
    for i=1:length(files)
            currentfile=files(i).name;
            readname=sprintf('%s/%s',basedir,currentfile);
            readdata=sortrows(sortrows(sortrows(cell2mat(cdfread(readname,'Variables',keepvars)),1),2),3);
            
            
            outfile=sprintf('%s/%s_%s.mat',basedir,currentfile(1:end-4),strjoin(keepvars,''));
            fprintf('%s to %s\n',currentfile,outfile);
            save(outfile,'readdata','-v7.3')
    end