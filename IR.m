function [ca, cb, cc, xnew, corr, eff, casd, cbsd, ccsd] = IR(x,f,numxcoef,numfcoef,lag,advance,loops)
%Usage: [xnew, corr, ca, cb,cc, eff] = IR(x,f,numxcoef,numfcoef,lag)
%Where ca are the x coefficients, cb the f coefficients
%Allows for a matrix of impulses
%***Important: Assumes more data points than impulses***%
 
if (nargin < 4)
    disp('Usage: function [ca, cb, cc, xnew, corr, eff, casd, cbsd, ccsd] = IR(x,f,numxcoef,numfcoef,lag,advance,loops)');
    disp('Where ca are the x coefficients, cb the f coefficients');
    disp('***Important: Assumes more data points than impulses***');
    error('');
end
if nargin <= 4 || isempty(lag)
    lag=0;
end
if nargin <= 5 || isempty(advance)
    advance=0;
end
if nargin <= 6
    loops=1;
end


casd=[];
cbsd=[];
ccsd=[];

%Make x and f row vectors for standardization purposes
xswitched=0;
if(length(x)~=size(x,2))
    x=x';
    xswitched=1;
end
if(length(f)~=size(f,2))
    f=f';
end

predstart=max(numxcoef,numfcoef)+1+lag-advance;

xstart=predstart-numxcoef-lag+advance;
fstart=predstart-numfcoef-lag+advance;

len=floor(length(x)-predstart-advance);

numimpulses=min(size(f));
    
Z=zeros(len,numxcoef+numfcoef*numimpulses+1);

%Must add +i-1 to shift column start point
for i=1:numxcoef
   Z(1:len,i)=x(xstart+i-1:xstart+i-1+len-1); 
end
for i=1:numfcoef
    for j=1:numimpulses
        Z(1:len,i+numxcoef+(j-1)*numfcoef)=f(j,fstart+i-1:fstart+i-1+len-1);
    end
end
Z(:,end)=1;

b=x(predstart:predstart+len-1);
Z=[Z(1:end,:) b'];

for a=1:(numxcoef+numfcoef*numimpulses+1+1) %+1 for mean-normalization coef (cc, column of 1s), and +1 for column of 'b'
    Z(isnan(Z(:,a)),:)=[];
end

b=Z(:,end);
A=Z(:,1:end-1);

if(loops==1)
    coef=A(1:end,:)\b;

    ca=coef(1:numxcoef);
    cb=coef(numxcoef+1:end-1);
    cc=coef(end);
else
    cas=zeros(loops,numxcoef);
    cbs=zeros(loops,numfcoef*numimpulses);
    ccs=zeros(loops,1);
    for i=1:loops
        randrows=randsample(1:length(b),length(b),'true');
        coef=A(randrows,:)\b(randrows);

        if(numxcoef>0), cas(i,:)=coef(1:numxcoef); end
        if(numfcoef>0), cbs(i,:)=coef(numxcoef+1:end-1); end
        ccs(i)=coef(end);
    end
    if(numxcoef>0), ca=mean(cas)'; else ca=double.empty(0,1); end
    if(numfcoef>0), cb=mean(cbs)'; else cb=double.empty(0,1); end
    cc=mean(ccs);
    if(numxcoef>0), casd=std(cas)'; else casd=[]; end
    if(numfcoef>0), cbsd=std(cbs)'; else cbsd=[]; end
    ccsd=std(ccs);
end



xtemp=x;
ftemp=f;

xnew=zeros(1,length(x));
xnew(1:predstart)=xtemp(1:predstart);

%Anywhere f is nan, don't predict, just copy data
iter=1:(length(f));
iter=iter(iter>=predstart+advance); %Don't use copied variables
iter=iter(iter<=length(f)-lag); %Allow space to predict 



for i=iter
    %xnew(i)=(xnew(i-numxcoef:1:i-1)'*ca)+(ftemp(i-numfcoef+1:1:i)'*cb)+cc;
    xnew(i+lag)=(xtemp(i-numxcoef:1:i-1)*ca)+(reshape(ftemp(:,i-numfcoef:1:i-1)',1,[])*cb)+cc;
    %xnew(i+lag)=(xnew(i-numxcoef:1:i-1)*ca)+(reshape(ftemp(:,i-numfcoef:1:i-1),1,[])*cb)+cc;
end

%xnew(isnan(f))=NaN;

%Calculate correlation here to save program from needing to strip NaNs
skip=(isnan(xnew) | isnan(xtemp));
skip(1:predstart+lag)=1;
corr=corrcoef(xnew(~skip),xtemp(~skip)); %Ignore first added bit
corr=corr(1,2);

eff=sum(xnew(predstart+1:end)>xnew(predstart:end-1) & xtemp(predstart+1:end)>xtemp(predstart:end-1))+sum(xnew(predstart+1:end)<xnew(predstart:end-1) & xtemp(predstart+1:end)<xtemp(predstart:end-1));
eff=eff/(length(xnew)-predstart);

if(xswitched) %If x came in as a column vector, make xnew a column vector
    xnew=xnew';
end
