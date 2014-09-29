function cellstr_of_struct=struct2cellstr(structure)

cellstr_fieldnames=fieldnames(structure);

ct=1;
for i=1:length(cellstr_fieldnames)
    if isnumeric(eval(['structure.' cellstr_fieldnames{i}]))
        numericarr=eval(['structure.' cellstr_fieldnames{i}]);
        if size(numericarr,1)>1 && size(numericarr,2)>1
            numericarr=reshape(numericarr,1,size(numericarr,1)*size(numericarr,2));
        else
            if size(numericarr,1)>size(numericarr,2) % size=[cols rows]
                numericarr=reshape(numericarr,1,size(numericarr,1)*size(numericarr,2));
            end
        end
        cellstr_of_struct{ct}=...
            [cellstr_fieldnames{i}, ' = ', num2str(numericarr)];
        ct=ct+1;
    elseif ischar(eval(['structure.' cellstr_fieldnames{i}]))
        cellstr_of_struct{ct}=...
            [cellstr_fieldnames{i}, ' = ', eval(['structure.' cellstr_fieldnames{i}])];
        ct=ct+1;
    elseif iscell(eval(['structure.' cellstr_fieldnames{i}]))
        currcell=eval(['structure.' cellstr_fieldnames{i}]);
        currcell=char(currcell{1});
        currfieldname=cellstr_fieldnames{i};
        for j=1:size(currcell,1)
            cellstr_of_struct{ct}=...
                [currfieldname, '(', num2str(j) ') = ', currcell(j,:)];
            ct=ct+1;
        end
    end
end