#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
	char* cmd;
	float cpu;
	float mem;
} proc;

typedef struct _list {
	proc node;
	struct _list* next;
} list;

int main(int argc, char* argv[]) {
	FILE* ps;
	size_t len =0;
	char* line;

	list* head = (list*)malloc(sizeof(list));
	list* itt;
	proc p;
	p.cmd = (char*)malloc(64);

	head->next = NULL;
	head->node.cmd = "";

	ps = popen("/bin/ps -Ao comm,pcpu,pmem --no-header", "r");
	while(getline(&line,&len,ps)!=-1) {
		
		p.cmd = (char*)malloc(64);
		sscanf(line, "%s\t%f %f\n", p.cmd, &p.cpu, &p.mem);
		char* stringStopper = p.cmd;
		while(stringStopper[0] != '\0')
			if(stringStopper[0] == '/')
				stringStopper[0] = '\0';
			else
				stringStopper++;
		itt = head;
		while(itt->next != NULL) {
			if(strcmp(p.cmd, itt->node.cmd) == 0) {
				itt->node.cpu += p.cpu;
				itt->node.mem += p.mem;
				break;
			}
			itt = itt->next;
		}
		if(itt->next == NULL) {
			itt->node = p;
			itt->next = (list*)malloc(sizeof(list));
			itt->next->node.cmd = "";
			itt->next->next = NULL;
		}
	}
	

	int count = 0;
	list* largest;
	list* start = head;
	while(count < 15 && head->next != NULL) {
		itt = head;
		largest = itt;
		
		while(itt->next != NULL) {
			if(itt->node.cpu > largest->node.cpu)
				largest = itt;
			itt = itt->next;
		}
		p = largest->node;
		largest->node = head->node;
		head->node = p;
		head = head->next;
		count++;
	}
	itt = start;
	count = 0;
	// printf("COMMAND          %%CPU  %%MEM\n");
	while(count++ < 15 && itt->next != NULL) {
		printf("%-15s %5.1f %5.1f\n", itt->node.cmd, itt->node.cpu, itt->node.mem);
		itt = itt->next;
	}
	pclose(ps);
	return 0;
}
