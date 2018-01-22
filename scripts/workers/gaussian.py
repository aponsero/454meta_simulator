#!/usr/bin/env python3

import random
import itertools
import sys, getopt
import argparse

def get_args():
  parser = argparse.ArgumentParser(description='provide a gaussian distribution for read size')
  parser.add_argument('-n', '--number', help='number of reads',
    type=int, metavar='NUMBER', required=True)

  parser.add_argument('-o', '--output', help='output directory',
    type=str, metavar='OUTPUT', required=True)

  return parser.parse_args()



def main():
   mu=350
   sigma=50
   args = get_args()
   outfile= args.output+"/gaussian.log"
   number= args.number

   f = open(outfile, 'w')
   
   for x in range(0,number):
      temp=int(random.gauss(mu, sigma))
      s=str(temp)
      f.write(s+'\n')

if __name__ == "__main__":main()
