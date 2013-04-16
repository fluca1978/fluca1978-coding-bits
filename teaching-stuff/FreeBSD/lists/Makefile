
slist: 
	gcc slists.c -o slists.exe

list:
	gcc lists.c -o lists.exe

tailq:
	gcc tailq.c -o tailq.exe

clean:
	rm *.exe 

run_slist: slist
	./slists.exe

run_list: list
	./lists.exe

run_tailq: tailq
	./tailq.exe

run: run_slist run_list run_tailq

