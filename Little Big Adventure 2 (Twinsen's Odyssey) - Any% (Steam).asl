//Hook the splitter to the dosbox process.

state("dosbox", "0.74.0.0")
{ 
	//Only works with Dosbox 0.74 (Steam version)
	ushort location : 0x74B6B0, 0x267CA0;
	ushort cinematic : 0x74B6B0, 0x25A90A;
}
 
//Called on splitter loading(don't forget to include the gamestart to the count)
init
{
 
    vars.splitCount = 10;       //
    print("Init");
}
 
//Game start, triggered after the intro cinematic
start
{  
    if ((old.cinematic == 66) && (current.cinematic == 0))
    {  
        //We keep a list of 'markers',
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
 
 
//Will reset the timer if the intro cinematic is playing
reset
{
    if ((current.cinematic == 66) && (current.cinematic != old.cinematic)) { print("Reset"); return true; }
}
 
//AutoSplits (alter as you like)
split
{
    //Twinsun
    if ((current.location == 23808) && (old.location == 3328)) { print("Split 1"); vars.splits[0] = true; return true; }
 
    //Emerald Moon
    if ((current.location == 19369) && (old.location == 6917) && (vars.splits[0])) { print("Split 2"); vars.splits[1] = true; return true; }
   
    //Otringal/Celebration
    if ((current.location == 10238) && (old.location == 13286) && (vars.splits[1])) { print("Split 3"); vars.splits[2] = true; return true; }
 
    //Francos
    if ((current.location == 8939) && (old.location == 22631) && (vars.splits[2])) { print("split 4"); vars.splits[3] = true; return true; }

    //Wannies
    if ((current.location == 24320) && (old.location == 8837) && (vars.splits[3]) && (!vars.splits[4])) { print("split 5"); vars.splits[4] = true; return true; }
 
    //Bees
    if ((current.location == 22411) && (old.location == 20139) && (vars.splits[4]) && (!vars.splits[5])) { print("split 6"); vars.splits[5] = true; return true; }
 
    //CX
    if ((current.location == 22263) && (old.location == 22411) && (vars.splits[5])) { print("split 7"); vars.splits[6] = true; return true; }
 
    //Palace
    if ((current.location == 6540) && (old.location == 6400) && (vars.splits[6])) { print("split 8"); vars.splits[7] = true; return true; }
   
    //Win
    if ((current.cinematic == 19463) && (old.cinematic == 0) && (vars.splits[7])) { print("split 9"); return true; }
   
    //default  
    return false;  
}
 
//Will print every cinematic/location changes
update
{  
    if (current.location != old.location)
    {
        print("location: " + current.location);
    }
   
    if (current.cinematic != old.cinematic)
    {
        print("cinematic: " + current.cinematic);
    }
}