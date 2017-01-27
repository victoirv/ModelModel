function CDFtoMAT(runname,keepvars,basepath)
%function CDFtoMAT(runname,keepvars,basepath)
%* For converting CDF files to mat files, only keeping certain variables
%* Cuts each slice from ~73MB to ~6MB 
%* Converts to v7.3 of mat file which can be read in chunks
%* Define variables to keep from cdf in arg 2 'keepvars'. Remember to also
%   define this as 'runvars' when using any model function.

if(nargin<1 || isempty(runname))
    runname='Victoir_Veibell_092716_1'; %Default to ux
end
if(nargin<2 || isempty(keepvars))
    keepvars={'x','y','z','ux','uy','uz','bx','by','bz','jx','jy','jz','rho','p'}; 
end
if(nargin<3 || isempty(basepath))
    basepath='/media/D/CCMC';
    %basepath='/home/victoir/Work/Differences/data'; 
end


    %Find all CDF files for each timestep and read them in to one array
    basedir=sprintf('%s/%s/GM_CDF/',basepath,runname);
    files=dir(sprintf('%s/*cdf',basedir));
    
    %Take each file, make new filename with kept vars and .mat extension
    for i=1:length(files)
            currentfile=files(i).name;
            readname=sprintf('%s/%s',basedir,currentfile);
            outfile=sprintf('%s/%s_%s.mat',basedir,currentfile(1:end-4),strjoin(keepvars,''));
            
            if(~exist(outfile,'file'))
                readdata=sortrows(sortrows(sortrows(cell2mat(cdfread(readname,'Variables',keepvars)),1),2),3);
                fprintf('%s done\n',currentfile);
                save(outfile,'readdata','keepvars','-v7.3')
            else
                fprintf('Already did %s\n',currentfile);
            end
            
    end