extends GutTest
class_name GutCollectionTest

func assert_almost_eq_deep(c1, c2, error_interval):
	if c1.size() != c2.size():
		_fail("collections are different sizes (%s vs %s)" % [c1.size(), c2.size()])
		return
	
	var failed_indexes := PackedInt32Array()
	for i in c2.size():
		if not _is_almost_eq(c1[i], c2[i], error_interval):
			failed_indexes.append(i)

	if failed_indexes.is_empty():
		_pass("%s approximately matches with %s with the error interval '%s'" % [c1, c2, error_interval])
		return
	
	var message := "%s elements do not match at indices: %s" % [failed_indexes.size(), failed_indexes]
	for i in failed_indexes:
		message += "\n[%s]: %s vs %s" % [i, c1[i], c2[i]]
	
	_fail(message)
