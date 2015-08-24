import csv
directory = '/home/c1016865/Raven_bound_data/parameter_files/'

def chunks(lst, chunk_size):
	"""
	Splits a list into chunks
	"""
	final_list = []
	i = 0
	list_len = len(lst)
	while i < list_len:
		final_list.append(lst[i:i+chunk_size])
		i += chunk_size
	return final_list

def write_params_to_file(directory, sffx, lst):
	"""
	Writes the paramters to a file
	"""
	data_file = open('%sparams_%i.csv' % (directory, sffx + 20), 'w')
	csv_wrtr = csv.writer(data_file)
	for row in lst:
		csv_wrtr.writerow(row)
	data_file.close()


rs = [(float(r11/5), float(r12/5)) for r11 in range(1,6) for r12 in range(1,6-r11)]
Ls = [i/10 for i in range(1,21)]
mu1s = [1]
mu2s = [0.5, 1.5, 2.0, 2.5]
ns = [0, 1, 2, 3, 4, 5]

all_parameter_sets = list(cartesian_product_iterator([ns, ns, mu1s, mu2s, rs, rs, Ls, Ls]))
chunk_size = int(len(all_parameter_sets)/20)
parameter_sets_chunks = chunks(all_parameter_sets, chunk_size)


for i in range(len(parameter_sets_chunks)):
	write_params_to_file(directory, i, parameter_sets_chunks[i])
