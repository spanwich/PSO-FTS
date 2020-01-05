function [particles,RMSEs,velocities] = particle(years,students)
    n = 50; % training data count
    
    RMSEs = zeros(10);
    particles = zeros(10,n-1);
    velocities = zeros(10,n-1);
    %Step 2.2 : update the personal best position of each
    %particle id, select the best particle, update the velocity vector and the position vector
    %Here I set D1 and D2 for training as 2000
    D1 = 2000;
    D2 = 2000;
    for id = 1:10
        [F,Ft,RMSE,U,V,Fnext,r] = optimal_interval(D1,D2,years,students,n);
        velocities(id,:) = V;
        particles(id,:) = r;
        RMSEs(id) = RMSE;
    end
end
%disp(RMSEs)