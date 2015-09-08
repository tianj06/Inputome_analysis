function ms = mergeStruct(struct1, struct2)

fnames1 = fieldnames(struct1);
fnames2 = fieldnames(struct2);    
if all(strcmp(fnames1, fnames2))
    for i = 1:length(fnames1)
        d1 = getfield(struct1,fnames1{i});
        d2 = getfield(struct2,fnames1{i});
        if isstruct(d1)&&isstruct(d2)
            d = mergeStruct(d1,d2);
        elseif ismatrix(d1)&&ismatrix(d2)
            sizeD1 = size(d1);
            sizeD2 = size(d2);
            if sizeD1(1)==sizeD2(1)
                d = [d1 d2];
            elseif sizeD1(2)==sizeD2(2)
                d = [d1; d2];
            else
                error('dimention of two matrix doesn''t match')
            end                
        elseif isstr(d1)&&isstr(d2)
            d = d1;
        else
            error('unknown data type')
        end
        ms.(fnames1{i}) = d;
    end
else
    error('two structs have different fields, can''t merge.')
end
end