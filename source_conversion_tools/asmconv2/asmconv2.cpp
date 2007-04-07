#include "stdafx.h"

map<string,string> directives;


int strstr(const string &inside, const string &find)
{
	int i1,i2;
	int i1limit=inside.size()-find.size()+1;
	int i2limit=find.size();
	for (i1=0;i1<i1limit;i1++)
	{
		for (i2=0;i2<i2limit;i2++)
		{
			if (inside[i1+i2]!=find[i2])
			{
				break;
			}
		}
		if (i2==i2limit)
		{
			return i1;
		}
	}
	return -1;
}

void init_directives()
{
	directives["%"]=	".skip";
//	directives["&"]=	".word";
//	directives["*"]=	"=";
//	directives["="]=	".byte";
	directives["["]=	".if";
	directives["|"]=	".else";
	directives["]"]=	".endif";
	directives["ALIGN"]=	".align";
	directives["CODE16"]=	".thumb";
	directives["CODE32"]=	".arm";
	directives["DATA"]=	".data";
	directives["DCB"]=	".byte";
	directives["DCD"]=	".word";
	directives["DCFD"]=	".double";
	directives["DCFS"]=	".float";
	directives["DCW"]=	".hword";
	directives["ELSE"]=	".else";
	directives["END"]=	".end";
	directives["ENDIF"]=	".endif";
	directives["EQU"]=	"=";
	directives["EXPORT"]=	".global";
	directives["EXTERN"]=	"@EXTERN";
	directives["GBLA"]=	"@GBLA";
	directives["GBLL"]=	"@GBLL";
	directives["GBLS"]=	"@GBLS";
	directives["GET"]=	".include";
	directives["GLOBAL"]=	".global";
	directives["IF"]=	".if";
	directives["IMPORT"]=	"@IMPORT";
	directives["INCBIN"]=	".incbin";
	directives["INCLUDE"]=	".include";
	directives["LCLA"]=	"@LCLA";
	directives["LCLL"]=	"@LCLL";
	directives["LCLS"]=	"@LCLS";
	directives["LTORG"]=	".ltorg";
	directives["MACRO"]=	".macro";
	directives["MAP"]=	"@MAP";
	directives["MEND"]=	".endm";
	directives["MEXIT"]=	".exitm";
	directives["RN"]=	".req";
	directives["SETA"]=	"=";
	directives["SETL"]=	"=";
	directives["SETS"]=	"=";
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

inline void splitline(const string &in_line, string &lab, string &ws1, string &ins,
						  string &ws2, string &rest, string &comment)
{
	string line=in_line;
	lab=""; ws1=""; ins=""; ws2=""; rest=""; comment="";
	
	//split line
	int x=0;
	int s=0;
	//find comment
	while (x<line.size() && line[x]!=';')
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
	while (x<comment.size() && comment[x]==';')
	{
		comment[x]='@';
		x++;
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
	//get rest
	s=x;
	rest=line.substr(s);
}


bool altersource(istream &in, ostream &out)
{
	string line;
	//ws3 includes comma
	string lab,ws1,ins,ws2,rest,comment;
	int in_macro=0;
	
	while (1)
	{
		getline(in,line);
		if (in.eof() || !in.good())
		{
			return true;
		}
		if (line.size()>0) //don't bother with empty lines
		{
			int do_rebuild=0;
			int is_equate=0;
			int macro_first_line=0;
			splitline(line, lab, ws1, ins, ws2, rest, comment);
			if (comment!="") do_rebuild=1;
			if (directives.find(ins)!=directives.end())
			{
				ins=directives[ins];
				do_rebuild=1;
				if (ins == "=" || ins == ".req") //equ
				{
					is_equate=1;
					lab=string(" ")+lab;
				}
				else if (ins == ".byte")
				{
					if (0<rest.size() && rest[0]=='\"')
					{
						ins = ".ascii";
					}
				}
				else if (ins == ".include" || ins==".incbin")
				{
					rest=string("\"")+rest+"\"";
				}
				else if (ins == ".macro") //macro
				{
					do_rebuild=0; //suppress the usual line rebuilding
					line=lab+ws1+ins;
					string newcomment;
					string nextline;
					string newws2;
					getline(in,nextline);
					splitline(nextline,lab,ws1,ins,newws2,rest,newcomment);
					if (lab!="")
					{
						cout << "oh noes!  Macro has label on next line!"<<endl;
					}
					nextline=" "+ins+ws2+newws2+rest+comment+newcomment;
					line+=nextline;
					in_macro=1;
					macro_first_line=1;
				}
				else if (ins == ".endm")
				{
					in_macro=0;

				}
			}
			if (!is_equate)
			{
				if (lab!="")
				{
					lab+=":";
					do_rebuild=1;
				}
			}
			//now check for local label reference
			int foundat;
			foundat=strstr(rest,"%f");
			if (foundat == -1) foundat=strstr(rest,"%F");
			if (foundat != -1)
			{
				rest.erase(&rest[foundat]);
				rest.erase(&rest[foundat]);
				if (isdigit(rest[foundat+1])) foundat++;
				rest.insert(&rest[foundat+1],'f');
				do_rebuild=1;
			}
			foundat=strstr(rest,"%b");
			if (foundat == -1) foundat=strstr(rest,"%B");
			if (foundat != -1)
			{
				rest.erase(&rest[foundat]);
				rest.erase(&rest[foundat]);
				if (isdigit(rest[foundat+1])) foundat++;
				rest.insert(&rest[foundat+1],'b');
				do_rebuild=1;
			}
			if (do_rebuild)
			{
				line=lab+ws1+ins+ws2+rest+comment;
			}
			//check for those damn {FALSE} and {TRUE} things
			foundat=strstr(line,"{FALSE}");
			if (foundat != -1)
			{
				line.erase(&line[foundat],&line[foundat+6]);
				line[foundat]='0';

			}
			foundat=strstr(line,"{TRUE}");
			if (foundat != -1)
			{
				line.erase(&line[foundat],&line[foundat+5]);
				line[foundat]='0';
			}
			//macro stuff
			if (in_macro)
			{
				do
				{
					foundat=strstr(line,"$");
					if (foundat!=-1)
					{
						if (macro_first_line)
						{
							line.erase(&line[foundat]);
						}
						else
						{
							line[foundat]='\\';
						}
					}
				} while (foundat != -1);
			}

		}
		out << line << endl;
	}
}

bool altersource(const char *infile, const char *outfile)
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
	return altersource(fin,fout);
}



int main(int argc, char* argv[])
{
	init_directives();
	if (argc<3)
	{
		cout << "syntax: <in_source> <out_source>" << endl;
		return 1;
	}
	
	altersource(argv[1],argv[2]);
	
	return 0;
}
