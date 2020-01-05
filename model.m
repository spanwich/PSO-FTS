function [ft,RMSEbest] = model(n)
    UniversityofAlabamaenrollments = importfile("C:\Users\xalan\MATLAB\Projects\pso_fts\University of Alabama enrollments.csv", [2, Inf]);
    years = sortrows(UniversityofAlabamaenrollments{:,1});
    students = sortrows(UniversityofAlabamaenrollments{:,6});

    yrang = years(1:n-1);
    ystudent = students(1:n-1);

    [particles,RMSEs,velocities] = particle(yrang,ystudent);

    iterMax = 1000;

    PGbest = particles;
    RMSEbest = RMSEs;
    Vbest = velocities;

    c1 = 2.05;
    c2 = 2.05;
    k = 2/abs(2-c1-c2-sqrt(((c1+c2)^2)-(4*(c1+c2))));
    iwMax = 0.9;
    iwMin = 0.4;
    %Step 2.3 to 2.5: Let the particle gbest denote the best particle,
    %velocity and objective values
    for iter = 2:iterMax
        iw = ((iwMax-iwMin) * ((iterMax - 1)/iterMax)) + iwMin;
        [particles,RMSEs,velocities] = particle(yrang,ystudent);
        for id = 1:10
            if RMSEs(id) < RMSEbest(id)
                Vbest(id) = k*(iw*velocities(id)+c1+rand()*(particles(id)-PGbest(id)+c2*rand()*(PGbest(id)-particles(id))));
                PGbest(id) = particles(id) + Vbest(id);
                RMSEbest(id) = RMSEs(id);
            end
        end
    end
    ft = PGbest;
    %writematrix(ft);
end