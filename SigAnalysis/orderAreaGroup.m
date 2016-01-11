function G = orderAreaGroup(brainArea,orderAreas)
    G = zeros(length(brainArea),1);
    for i = 1:length(orderAreas)
        G(strcmp(brainArea,orderAreas{i})) = i;
    end
