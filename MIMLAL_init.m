function [B,V,AB,AV,Anum,trounds,costs,norm_up,step_size0,num_sub,lambda,opts,n_repeat]=MIMLAL_init(init_data, init_targets)
% initialization

d=size(init_data{1},1);
n_class=size(init_targets,2);
n_repeat=4;
D=100;
num_sub=1;
norm_up=10;
lambda=0.0000001;%.0000001;
step_size0=0.001;
AB=0;
AV=0;
Anum=0;
trounds=0;
opts.norm=1;
opts.average_size=1;
opts.average_begin=0;

costs=1./(1:n_class);
for k=2:n_class
    costs(k)=costs(k-1)+costs(k);
end

V=normrnd(0,1/sqrt(d),D,d); % D*m
B=normrnd(0,1/sqrt(d),D,n_class*num_sub); % D*n_class
for k=1:d
    tmp1=V(:,k);
    if(tmp1>norm_up)
        V(:,k)=tmp1*norm_up/norm(tmp1);
    end
end
for k=1:n_class*num_sub
    tmp1=B(:,k);
    if(tmp1>norm_up)
        B(:,k)=tmp1*norm_up/norm(tmp1);
    end
end