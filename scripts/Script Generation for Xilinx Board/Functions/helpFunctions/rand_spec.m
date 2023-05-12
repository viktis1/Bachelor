function [r] = rand_spec(a,b,DIM)
%RAND_SPEC: Returns DIM(1) by DIM(2) random numbers uniformly distributed
%between a & b. 

r = (b-a).*rand(DIM) + a;
end

