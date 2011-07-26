Poor man VMware consolidated Backup
===================================

VMware offre un pacchetto di backup per le macchine virtuali: VCB (VMware consolidated Backup): http://www.vmware.com/products/vi/cb_overview.html

Il VCB non fa altro che:

* eseguire uno snapshot di una VM
* clonare i dischi virtuali della VM
* consolidare lo snapshot (rimozione dello snapshot)

I vantaggi di un backup del genere sono:

* si ha il backup una macchina virtuale intera
* non ci sono downtime: lo snapshot si puo' fare a caldo
* se i vmware tools fanno il loro dovere il filesystem dovrebbe essere consistente

Gli svantaggi sono:

* si ha il backup di una macchina virtuale intera (leggi: no incrementali)
* si hanno gli stessi limiti derivati dall'uso degli snapshot: no RDM, ecc..

In buona sostanza il VCB è un buon sistema per il disaster recovery (se i paletti imposti dall'uso degli snapshot non sono troppo restrittivi).

E' possibile implementare un sistema di backup molto simile automatizzando le operazioni di snapshot, cloning e consolidation tramite uno script.

Lo script in questione è pmvcb: pmvcb esegue le operazioni sopra elencate su un host ESXi.

Di seguito l'help:

    Usage: ./pmvcb -v [VM] -d [DIR] -h [host] <options>
    
    options:
    	-v <vm>		Virtual machine to backup [*]
	-d <dir>	Remote directory to store backup [*]
	-h <host>	ESXi host [*]
	-u <user>	ESXi username (default: root)
	-f <opts>	vmkfstool optons (default: "-a lsilogic -d zeroedthick")
	-o		overwrite existent backups
	-q		use quiesce snapshot
	-s <opts>	ssh options (default: "-i /var/lib/bacula/.ssh/id_rsa")
	-L <cmd>	local command executed after backup of virtual disks, this command is executed on local machine
	-R <cmd>	remote command executed on ESXi host after local command execution


    [*] required options

come opzioni obbligatorie richiede il nome della VM da backuppare (-v), la directory di appoggio in cui clonare i dischi (-d) e l'host ESXi a cui collegarsi (-h). 
Tramite l'opzione -f è possibile specificare diverse opzioni al comando vmkfstool utilizato per le operazioni di cloning, tramite -q richiede un'operazione di Quiescing prima di effettuare lo snapshot.
-s istruisce il comando ssh (es. ad usare l'autenticazione con chiave RSA).
-L e -R eseguono comandi rispettivamente e nell'ordine sull'host locale e sull'host remoto.
 

**pmvcb si occupa di:**

1. verificare che la virtual machine non abbia dischi indipendent oppure RDM.
2. verificare che non ci siano snapshot attivi sulla virtual machine
3. eseguire lo snapshot
4. clonare i dischi e il .vmx della virtual machine nella directory specificata dall'opzione -d
5. consolidare lo snapshot creato
6. eseguire i comandi specificati da -L localmente


