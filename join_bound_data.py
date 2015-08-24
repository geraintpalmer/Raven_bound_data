"""
Usage: draw_graph_vary_L.py <dir_name> <ran>

Arguments
    dir_name    : name of the directory from which to read in data files
    ran 	    : range of data files
"""
import docopt
import csv

def import_bound_data_file(directory, sffx):
	"""
	Imports the bound data
	"""
	bound_data = []
	bound_file = open('%sbound_data%i.csv' % (directory, sffx), 'r')
	rdr = csv.reader(bound_file)
	for row in rdr:
		bound_data.append(row)
	bound_file.close()
	return bound_data

def write_to_file(directory, lst):
	"""
	Writes the big list to a file
	"""
	data_file = open('%sbound_data.csv' % directory, 'w')
	csv_wrtr = csv.writer(data_file)
	for row in lst:
		csv_wrtr.writerow(row)
	data_file.close()



if __name__ == '__main__':
	arguments = docopt.docopt(__doc__)
	directory = arguments['<dir_name>']
	ran = int(arguments['<ran>'])
	big_list = []
	for i in range(ran):
		a = import_bound_data_file(directory, i)
		big_list += a
	list_to_write = big_list
	write_to_file(directory, list_to_write)