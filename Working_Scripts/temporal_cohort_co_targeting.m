function [co_target_prob,neurons_used,similarity_distributions] = temporal_cohort_co_targeting(nl,annotations,sim_mat,adjacency,random,sim_thresh)
 
tc_unique = unique(annotations(:,[2,4,5,6]),'rows');
[~,tc_index] = ismember(annotations(:,[2,4,5,6]),tc_unique,'rows')

if exist('random','var') && random == 1
    if exist('sim_thresh','var')
    else
        sim_thresh = [0:.1:1];
    end
    for jj = 1:length(sim_thresh)

    for kk = 1:1000
        clc
        display(kk/1000);
        for i = 1:100
            sim = -1;
            while sim<sim_thresh(jj)
                tc_index_randomized = tc_index(randperm(length(tc_index)));
                % Choose a temporal cohort.  Make sure the temporal
                % cohort has at least two neurons in it. Then pick a pair of
                % neurons and get their connectivity.  Make sure the first neuron
                % has at least some connectivity to other neurons in the dataset.
                neuron_ip_1_connections = 0;
                while neuron_ip_1_connections<1
                    cohort_ip_index = 0;
                    while length(cohort_ip_index) < 2
                        cohort_ip = randperm(max(tc_index_randomized),1);
                        cohort_ip_index = find(tc_index_randomized==cohort_ip);
                        if length(unique(tc_index(cohort_ip_index)))<2
                            cohort_ip_index = 0;
                        else
                        end
                    end
                    neurons_ip = cohort_ip_index(randperm(length(cohort_ip_index),2));
                    % Get the connectivity of neuron_ip_1 and make sure it has at least one
                    % connection in our dataset.
                    neuron_ip_1_connection_index = find(adjacency(neurons_ip(1),:) > 0);
                    neuron_ip_1_connections = length(neuron_ip_1_connection_index);
                    neuron_ip_1_connection_cohorts = tc_index(neuron_ip_1_connection_index);
                end
                sim = sim_mat(neurons_ip(1),neurons_ip(2));
                similarity_distributions{jj}(kk,i) = sim;
                neurons_used{jj}(kk,i,:) = [nl(neurons_ip(1)).SkIDs,nl(neurons_ip(2)).SkIDs];
            end

            % Get connectivity of neuron_ip_2
            neuron_ip_2_connection_index = find(adjacency(neurons_ip(2),:) > 0);
            neuron_ip_2_connection_cohorts = tc_index(neuron_ip_2_connection_index);
            
            % Check if any of neuron_ip_2 connections are also of cohort_jq
            cohort_intersection = intersect(neuron_ip_1_connection_cohorts,neuron_ip_2_connection_cohorts);
            if isempty(cohort_intersection)
                co_target_prob{jj}(kk,i) = 0;
            else
                co_target_prob{jj}(kk,i) = 1;
            end
        end

    end  
    

    end

else
    for kk = 1:1000
    clc
    display(kk/1000)
        for i = 1:100
            sim = -1;
            while sim<0
                % Choose a temporal cohort.  Make sure the temporal
                % cohort has at least two neurons in it. Then pick a pair of
                % neurons and get their connectivity.  Make sure the first neuron
                % has at least some connectivity to other neurons in the dataset.
                neuron_ip_1_connections = 0;
                while neuron_ip_1_connections<1 
                    cohort_ip_index = 0;
                    while length(cohort_ip_index) < 2 % While the temporal cohort size < 2
                        cohort_ip = randperm(max(tc_index),1); % Choose a temporal cohort
                        cohort_ip_index = find(tc_index==cohort_ip); % Find the neuronsin the temporal cohort 
                    end
                    neurons_ip = cohort_ip_index(randperm(length(cohort_ip_index),2)); % Choose two neurons from the temporal cohort
                    
                    % Get the connectivity of neuron_ip_1 and make sure it has at least one
                    % connection in our dataset.
                    neuron_ip_1_connection_index = find(adjacency(neurons_ip(1),:) > 0);
                    neuron_ip_1_connections = length(neuron_ip_1_connection_index);
                    neuron_ip_1_connection_cohorts = tc_index(neuron_ip_1_connection_index);
                end
                sim = sim_mat(neurons_ip(1),neurons_ip(2));
                similarity_distributions(kk,i) = sim;
                neurons_used(kk,i,:) = [nl(neurons_ip(1)).SkIDs,nl(neurons_ip(2)).SkIDs];
            end

            % Get connectivity of neuron_ip_2
            neuron_ip_2_connection_index = find(adjacency(neurons_ip(2),:) > 0);
            neuron_ip_2_connection_cohorts = tc_index(neuron_ip_2_connection_index);

            % Check if any of neuron_ip_2 connections are also of cohort_jq
            cohort_intersection = intersect(neuron_ip_1_connection_cohorts,neuron_ip_2_connection_cohorts);
            if length(cohort_intersection) > 0
                co_target_prob(kk,i) = 1;
            else
                co_target_prob(kk,i) = 0;
            end


        end
    
    end
end

