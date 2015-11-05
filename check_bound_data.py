import csv

def import_bound_data_file(directory):
	"""
	Imports the bound data
	"""
	bound_data = []
	bound_file = open('%sbound_data.csv' % directory, 'r')
	rdr = csv.reader(bound_file)
	for row in rdr:
		bound_data.append(row)
	bound_file.close()
	return bound_data


def does_bound_fail(lst):
	"""
	Returns True if bound fails, False otherwise
	"""
	w11 = max(float(lst[-6]), float(lst[-5]))
	w12 = max(float(lst[-4]), float(lst[-3]))
	w2 = float(lst[-2])
	w = float(lst[-1])
	rhs = min(w11, w12, w2)
	if w > rhs:
		return True
	else:
		return False

def write_failed_data(directory, lst):
	"""
	Writes the big list to a file
	"""
	data_file = open('%sfailed_data.csv' % directory, 'w')
	csv_wrtr = csv.writer(data_file)
	for row in lst:
		csv_wrtr.writerow(row)
	data_file.close()


if __name__ == '__main__':
	directory = 'parameter_files/'
	bound_data = import_bound_data_file(directory)
	failed_data = [bound_data[i] for i in range(len(bound_data))if does_bound_fail(bound_data[i])]
	write_failed_data(directory, failed_data)