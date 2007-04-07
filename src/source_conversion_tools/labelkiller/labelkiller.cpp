#include "stdafx.h"

bool readlabels(istream &in, set<string>&labels)
{
	string line;
	while (1)
	{
		getline(in,line);
		if (!in.good() || line==string() )
		{
			return true;
		}
		labels.insert(line);
	}
}

bool readlabels(const char *filename, set<string>&labels)
{
	ifstream fin;
	fin.open(filename);
	if (!fin.good())
	{
		fin.close();
		return false;
	}
	else
	{
		return readlabels(fin,labels);
	}
}

bool islabelchar(int c)
{
	if (  (c>='0' && c<='9') || (c>='A' && c<='Z') || (c>='a' && c<='z') || c=='_' )
	{
		return true;
	}
	else
	{
		return false;
	}
	
}

inline void splitline(const string &in_line, string &lab, string &ws1, string &ins, string &ws2,
					  string &rd, string &ws3, string &equ, string &rest, string &comment)
{
	string line=in_line;
	lab=""; ws1=""; ins=""; ws2=""; rd=""; ws3=""; equ=""; rest=""; comment="";
	
	//split line
	int x=0;
	int s=0;
	//find comment
	if (x<line.size() && line[x]!=';')
	{
		x++;
	}
	if (x<line.size() && line[x]==';')
	{
		comment=line.substr(x);
		line=line.substr(s,x-s);  //remove comment from line
	}
	x=0;
	s=0;
	//label present?
	if (x<line.size() && !isspace(line[x]))
	{
		//get label
		while (x<line.size() && !isspace(line[x]))
		{
			x++;
		}
		lab=line.substr(s,x-s);
	}
	//get ws1
	s=x;
	while (x<line.size() && isspace(line[x]))
	{
		x++;
	}
	ws1=line.substr(s,x-s);
	//get ins
	s=x;
	while (x<line.size() && !isspace(line[x]))
	{
		x++;
	}
	ins=line.substr(s,x-s);
	//get ws2
	s=x;
	while (x<line.size() && isspace(line[x]))
	{
		x++;
	}
	ws2=line.substr(s,x-s);
	//get rd
	s=x;
	while (x<line.size() && islabelchar(line[x]))
	{
		x++;
	}
	rd=line.substr(s,x-s);
	//get ws3
	s=x;
	while (x<line.size() && !islabelchar(line[x]))
	{
		x++;
	}
	ws3=line.substr(s,x-s);
	//get equ
	s=x;
	while (x<line.size() && islabelchar(line[x]))
	{
		x++;
	}
	equ=line.substr(s,x-s);
	//get rest
	s=x;
	rest=line.substr(s);
}


bool altersource(istream &in, ostream &out, const set<string> &labels)
{
	string line;
	//ws3 includes comma
	string lab,ws1,ins,ws2,rd,ws3,equ,rest,comment;
	
	while (1)
	{
		getline(in,line);
		if (in.eof() || !in.good())
		{
			return true;
		}
		if (line.size()>0) //don't bother with empty lines
		{
			int changed=0;
			splitline(line, lab, ws1, ins, ws2, rd, ws3, equ, rest, comment);
			if (ins.substr(0,3)=="ldr" || ins.substr(0,3)=="str" || ins.substr(0,3)=="adr")
			{
				//check if equ is inside labels
				if (labels.find(equ)!=labels.end())
				{
					ins+="_";
					changed=1;
				}

			}
			if (changed)
			{
				line=lab+ws1+ins+ws2+rd+ws3+equ+rest+comment;
			}
		}
		out << line << endl;
	}
}

bool altersource(const char *infile, const char *outfile, const set<string> &labels)
{
	ifstream fin;
	fin.open(infile);
	if (!fin.good())
	{
		fin.close();
		return false;
	}
	ofstream fout;
	fout.open(outfile);
	if (!fout.good())
	{
		fin.close();
		fout.close();
		return false;
	}
	return altersource(fin,fout,labels);
}



int main(int argc, char* argv[])
{
	set<string> labels;
	if (argc<4)
	{
		cout << "syntax: <labelfile> <in_source> <out_source>" << endl;
		return 1;
	}
	
	readlabels(argv[1],labels);
	altersource(argv[2],argv[3],labels);
	
	return 0;
}
