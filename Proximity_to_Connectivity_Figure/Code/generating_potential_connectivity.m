%% Calculate synapse densities
% Calculate densities for a range of values
tic
for i = 1:length(nl)
    input_densities = synapse_density(nl(i),2,5000);
    output_densities = synapse_density(nl(i),1,5000);
    nl(i).output_density = output_densities;
    nl(i).input_density = input_densities; clear densities
end
toc
%% 
tic
for i = 1:length(nl)
    for j = 1:length(nl)
        [~,n_real,n_possible] = filling_fraction(nl(i),nl(j))
        real_adjacency(i,j) = n_real; clear n_real
        potential_adjacency(i,j) = n_possible; clear n_possible
    end
end
toc
%%
adj = get_adjacency(nl,0)
binary_potential = potential_adjacency
binary_adj = adj

binary_potential(binary_potential>1) = 1
binary_adj(binary_adj>1) = 1

corr2(binary_potential,binary_adj)


%% histogram of filling fractions

ff = adj./potential_adjacency
ff(isnan(ff)) = -1

histogram(ff(:))

idx = find(ff>1)
[ii,jj] = ind2sub(size(adj),idx)
figure; hold on
plot_neurons(nl(18),'m',1,3,1,1,0)
plot_neurons(nl(22),'g',1,3,1,1,0)