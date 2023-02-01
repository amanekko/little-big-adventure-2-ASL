// DOSBox LBA2
state("dosbox")
{  
//Only works with Dosbox 0.74-2.1
	ushort loc : 0x75B6D0, 0x04D178;
	ushort cin : 0x75B6D0, 0x2B0880;
}

// TLBA2 Classic 
state("TLBA2C")
{ 
//Only works with TLBA2C v3.2.4
	ushort loc :  0x47FEE8; 
	ushort cin : 0x4BDAC0;
	ushort locgog :  0x47DCE8; 
	ushort cingog : 0x4BB878;
}
 
 
// Called on splitter loading(don't forget to include the gamestart to the count)
init
{
 
    vars.splitCount = 10;
    print("Init");
}
 
// Game start, triggered after the intro cin
start
{  
print("game.ProcessName: " + game.ProcessName);

    if (((game.ProcessName == "DOSBox") && (old.cin == 66) && (current.cin != old.cin)) || ((game.ProcessName == "TLBA2C") && ((old.cin == 18388) && (current.cin != old.cin)) || ((old.cingog == 18388) && (current.cingog != old.cingog))))
    {  
        // We keep a list of 'markers',
        bool[] splits = new bool[vars.splitCount];
        for(int i = 0; i < vars.splitCount; i++)
        {
            splits[i] = false;
        }
        vars.splits = splits;
        print("Start");
        return true;
    }      
}
 
 
// Will reset the timer if the intro cin is playing
reset
{
    if (((game.ProcessName == "DOSBox") && (current.cin == 66) && (old.cin != current.cin)) || ((game.ProcessName == "TLBA2C") && ((current.cin == 18388) && (old.cin != current.cin)) || ((current.cingog == 18388) && (old.cingog != current.cingog))))
    {
        print("Reset");
        return true;
    }
}
 
// AutoSplits (alter as you like)
split
{

    //Twinsun
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 23808) && (old.loc == 3328)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 23808) && (old.locgog == 3328)) && (!vars.splits[0])) { print("Split 1"); vars.splits[0] = true; return true; }
    
    //Emerald Moon
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 19369) && (old.loc == 6917)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 19369) && (old.locgog == 6917)) && (vars.splits[0]) && (!vars.splits[1])) { print("Split 2"); vars.splits[1] = true; return true; }
    
    //Tourism
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 10238) && (old.loc == 13286)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 10238) && (old.locgog == 13286)) && (vars.splits[1]) && (!vars.splits[2])) { print("Split 3"); vars.splits[2] = true; return true; }
    
    //Francos
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 8939) && (old.loc == 22631)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 8939) && (old.locgog == 22631)) && (vars.splits[2]) && (!vars.splits[3])) { print("split 4"); vars.splits[3] = true; return true; }

    //Wannies
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 24320) && (old.loc == 8837)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 24320) && (old.locgog == 8837)) && (vars.splits[3]) && (!vars.splits[4])) { print("split 5"); vars.splits[4] = true; return true; }
    
    //Bees
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 22411) && (old.loc == 20139)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 22411) && (old.locgog == 20139)) && (vars.splits[4]) && (!vars.splits[5])) { print("split 6"); vars.splits[5] = true; return true; }
    
    //CX
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 22263) && (old.loc == 22411)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 22263) && (old.locgog == 22411)) && (vars.splits[5]) && (!vars.splits[6])) { print("split 7"); vars.splits[6] = true; return true; }
    
    //Palace
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.loc == 6540) && (old.loc == 6400)) || ((game.ProcessName == "TLBA2C") && (current.locgog == 6540) && (old.locgog == 6400)) && (vars.splits[6]) && (!vars.splits[7])) { print("split 8"); vars.splits[7] = true; return true; }
    
    //Win
    if (((game.ProcessName == "DOSBox") || (game.ProcessName == "TLBA2C") && (current.cin == 19463)) || ((game.ProcessName == "TLBA2C") && (current.cingog == 22796)) && (vars.splits[7])) { print("split 9"); return true; }
    
    //default  
    return false;  
}
 
// Will print every cin/loc changes
update
{  
    if (current.loc != old.loc)
    {
        print("loc: " + current.loc);
    }
   
    if (current.cin != old.cin)
    {
        print("cin: " + current.cin);
    }

    if (current.locgog != old.locgog)
    {
        print("locgog: " + current.locgog);
    }
   
    if (current.cingog != old.cingog)
    {
        print("cingog: " + current.cingog);
    }
}