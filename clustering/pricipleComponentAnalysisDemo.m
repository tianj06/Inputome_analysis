%% Principle component simulation
x = 0:100;
shapeVec = sin(x/50*3.14);
% add Gaussian noise
noisedVec = awgn(shapeVec,20);
figure;
plot(noisedVec)
% make multiple observations
N_obs = 200;
sim_obs = zeros(N_obs,length(x));
%%
% 1) only noise is different
for i = 1:N_obs
    sim_obs(i,:) = awgn(shapeVec,20);
end
figure;
subplot(2,4,1)
plot(sim_obs(1:20:end,:)')
[eigvect,proj,eigval] = princomp(sim_obs);
subplot(2,4,5)
plot(eigvect(:,1))

% 2) signal is randomly scaled
for i = 1:N_obs
    scaleAmplitude = rand;
    sim_obs(i,:) = awgn(scaleAmplitude*shapeVec,20);
end
subplot(2,4,2)
plot(sim_obs(1:20:end,:)')
[eigvect,proj,eigval] = princomp(sim_obs);
subplot(2,4,6)
plot(eigvect(:,1))
% 3) offset is randomly added
for i = 1:N_obs
    scaleAmplitude = rand;
    sim_obs(i,:) = awgn(shapeVec,20)+ 2*scaleAmplitude;
end
subplot(2,4,3)
plot(sim_obs(1:20:end,:)')
[eigvect,proj,eigval] = princomp(sim_obs);
subplot(2,4,7)
plot(eigvect(:,1))
% 4) both signal scale and offset is randomly scaled
for i = 1:N_obs
    scaleAmplitude = rand;
    sim_obs(i,:) = awgn(rand*shapeVec,20)+ 2*scaleAmplitude;
end
subplot(2,4,4)
plot(sim_obs(1:20:end,:)')
[eigvect,proj,eigval] = princomp(sim_obs);
subplot(2,4,8)
plot(eigvect(:,1))
%%
for i = 1:N_obs
    scaleAmplitude = rand;
    %noise = 0.1*randn(1,101);
    sim_obs(i,:) = awgn(scaleAmplitude*shapeVec,20); %scaleAmplitude*shapeVec + noise; %
end

%sim_obs = sim_obs - repmat(mean(sim_obs),N_obs,1);
C = sim_obs*sim_obs';
[V,D] = eig(C);
[~,i] = max(abs(diag(D)));
cEigVector = V(:,i);
output = cEigVector'*sim_obs;
subplot(1,3,1);plot(sim_obs(1:20:end,:)')
subplot(1,3,2);plot(output)
[eigvect,proj,eigval] = princomp(sim_obs);
subplot(1,3,3)
plot(eigvect(:,1))
%%
u = sim_obs(:,:);
%u = u - repmat(mean(u),2,1);

figure;
subplot(1,3,1);plot(u');legend('u1','u2');xlabel('t')
subplot(1,3,2);scatter(u(1,:),u(2,:));xlabel('u1');ylabel('u2')
C = u*u';
[V,D] = eig(C);
[~,i] = max(abs(diag(D)));
cEigVector = V(:,i);
output = cEigVector'*u;
[eigvect,proj,eigval] = princomp(u);
subplot(1,3,3); plot([output' eigvect(:,1)]);xlabel('t')