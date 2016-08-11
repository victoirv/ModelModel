function ModelModelsAll(varnum)
if(nargin<1)
    varnum=9; %Default to B_z
end

runname='Victoir_Veibell_041316_1'; 
dataheaders={'x','y','z','x','y','z','B_x','B_y','B_z','jx','jy','jz','ux','uy','uz','p','rho'};



filename=sprintf('data/%s/DifferencesData_%s_AllCuts.mat',runname,runname);

if(exist(filename,'file'))
    load(filename)
else

    [status,ncuts]=system(sprintf('ls -1 data/%s/data/cuts/ | wc -l',runname));
    ncuts=str2double(ncuts);
    for i=1:ncuts
        data(i,:,:)=dlmread(sprintf('data/%s/data/cuts/Step_%02d_Y_eq_0.txt',runname,i-1)); 
    end

    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};

    inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));
    
    for i=1:(ncuts-1)
        bininputs(i,:)=median(inputs((i-1)*30+1:i*30,:));
    end
    bininputs(ncuts,:)=median(inputs((ncuts-1)*30+1:end,:));
    
    save(filename,'data','inputs','bininputs','inputvars');
end


%Cut across X and test correlations
warning('off','all') %lots of rank deficient warnings
xs=-200:1:30;
zs=-40:1:40;
for i=1:length(xs)
    xi=(data(1,:,1)==xs(i));
    for j=1:length(zs)
        zi=(data(1,:,3)==zs(j));
        mi=intersect(find(xi),find(zi));
        [~,~,~,~,corrs(i,j)]=IR(data(:,mi,varnum),bininputs(:,8:15),0,3);
        pointvals(i,j)=mean(data(:,mi,varnum));
    end
end

figure
surf(xs,zs,corrs','FaceLighting','phong')
colorbar
view(0,90)
title(sprintf('Correlation of predicted %s and theoretical %s',dataheaders{varnum},dataheaders{varnum}))

print('-depsc2',sprintf('figures/ModelModelCorrelation_%s.eps',dataheaders{varnum})); 
print('-dpng','-r200',sprintf('figures/PNGs/ModelModelCorrelation_%s.png',dataheaders{varnum})); 


ignore=1;


%scale = @(x) sign(x).*log(abs(x)); %since there are some extreme points, you want to scale them to fit on a plot, but some are negative
%scale = @(x) ((x>0).*sqrt(x))+(-(x<0).*sqrt(-x));


close all;
figure
plot(pointvals(:),corrs(:),'+') %Using scatter() makes it crash, for some reason
xlim(quantile(pointvals(:),[0.01 0.99])) %Because there are usually one or two extreme points that throw the axis off
grid on
ylabel('Correlation')
xlabel(sprintf('Mean %s across all cuts',dataheaders{varnum}));

print('-depsc2',sprintf('figures/ModelModelCorrelation_Scatter_%s.eps',dataheaders{varnum})); 
print('-dpng','-r200',sprintf('figures/PNGs/ModelModelCorrelation_Scatter_%s.png',dataheaders{varnum})); 


%{
for ctest=8:15
   [~,~,~,~,corr]=IR(data(:,9),bininputs(:,ctest),0,3);
   fprintf('%s: %2.3f\n',inputvars{ctest},corr);
end

[~,~,~,~,corr]=IR(data(:,9),bininputs(:,8:15),0,3);
fprintf('All: %2.3f\n',corr);

plot(data(:,9)); %check for Bz flip
%}

%grep -h -e "-200.000000 0.000000 -47.000000" ../Differences/output/Brian_Curtis_042213_2/data/cuts/*

%{
    test=dlmread(sprintf('../Differences/output/%s/data/cuts/Step_70_Y_eq_0.txt',runname));
    x=unique(test(:,1));
    z=unique(test(:,3));
    d=reshape(test(:,8),length(x),[]);
    surf(x,z,d') %Make sure we're looking at the magnetosphere?
  %}  
    
    %look at columns 8, 10, 11, 12?
