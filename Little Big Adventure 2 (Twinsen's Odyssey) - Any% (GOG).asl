// DOSBox LBA2
state("dosbox")
{  
    //Only works with Dosbox 0.74-2.1
	ushort location : 0x75B6D0, 0x04D178;
	ushort cinematic : 0x75B6D0, 0x2B0880;
}

// TLBA2 Classic 
state("TLBA2C", "Classic v3.2.4 Steam")
{ 
    //Only works with Steam TLBA2C v3.2.4
	ushort location : 0x47FEE8; 
	ushort cinematic : 0x4BDAC0;

}

state("TLBA2C", "Classic v3.2.4 GOG")
{ 
    //Only works with GOG TLBA2C v3.2.4
	ushort location : 0x47DCE8; 
	ushort cinematic : 0x4BB878;
}

 
 
// Called on splitter loading
init
{
    // Catch the version of the game 
    switch (modules.First().ModuleMemorySize) 
    {
        case 5152768:         
            version = "Classic v3.2.4 GOG";
            break;
		case 5160960: 
            version = "Classic v3.2.4 Steam";
            break;
        case 34058240: 
            version = "DOSBox";
            break;
        default:
        print("Unknown version detected");
        return false;
    }    
    print("Version: " + version);

    // Init locations variables for Splits
    vars.locationsOld = new List<int>() {3328, 6917, 13286, 22631, 8837, 20139, 22411, 6400};
    vars.locationsCurrent =  new List<int>() {23808, 19369, 10238, 8939, 24320, 22411, 22263, 6540};

    // Init cinematics variables for start/end
    switch (version) 
    {
        case "Classic v3.2.4 GOG":    
		case "Classic v3.2.4 Steam": 
            vars.startCinematicOld = 18388;
            vars.endCinematicCurrent = 22796;
            break;
        case "DOSBox": 
        default:
            vars.startCinematicOld = 66;
            vars.endCinematicCurrent = 19463;
            break;        
    }

    // Init Splits
    vars.splitCount = 9;
    vars.completedSplits = 0;

}

// Game start, triggered after the intro cinematic
start
{    
    if (old.cinematic == vars.startCinematicOld  && current.cinematic == 0 )
    { 
        // ⚠️ Important to reset the value to 0 
        vars.completedSplits = 0;
        print("Start");        
        return true;
    }      
}
 
 
// Will reset the timer if the intro cin is playing
reset
{
    if (current.cinematic == vars.startCinematicOld && old.cinematic != current.cinematic)
    {
        print("Reset");
        return true;
    } 
}
 
// AutoSplits
split
{
    // If it is the end, force splitting all segments
    if(current.cinematic == vars.endCinematicCurrent) {
        vars.completedSplits = vars.splitCount;
    }

    // Split Segments
    if(
        vars.completedSplits < vars.splitCount && current.location == vars.locationsCurrent[vars.completedSplits] && old.location == vars.locationsOld[vars.completedSplits] ||
        vars.completedSplits >= vars.splitCount
    ) {
        if(vars.completedSplits < vars.splitCount) vars.completedSplits++;
        print("Split " + vars.completedSplits);
        return true;
    }

    return false;     
}
 
// Will print every cinematic/location changes
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