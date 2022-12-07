sum_inventory(InventoryString, InventorySum) :-
	split_string(InventoryString, "\n", "", ItemStrings),
	maplist(number_string, ItemNums, ItemStrings),
	sum_list(ItemNums, InventorySum).

main :-
	read_file_to_string('../../input', Input, []),
	string_concat(TrimmedInput, "\n", Input),
	atomic_list_concat(InventoryStrings, '\n\n', TrimmedInput),
	maplist(sum_inventory, InventoryStrings, InventorySums),
	sort(InventorySums, SortedSums),
	reverse(SortedSums, [M1|[M2|[M3|_]]]),
	sum_list([M1, M2, M3], MaxSum),
	write(MaxSum).
