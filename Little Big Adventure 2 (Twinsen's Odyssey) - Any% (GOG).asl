// ==========================================
// TLBA2 – Dynamic Multi-Category Autosplitter
// Scenes / Items / Misc
// ==========================================

// -------- STATES --------

state("TWINSEN", "Win95") {}
state("TLBA2C", "Classic") {}
state("dosbox", "DOSBox") {}

// -------- STARTUP --------

startup
{
    vars.Log = (Action<string>)(s => print("[LBA2] " + s));
    vars.varLabels = new Dictionary<int, string>();
    vars.varTargets = new Dictionary<string, int>();


    // Scene Splits - Load ALL XMLs
    vars.xmlNames = new List<string>();
    try
    {
        string baseDir = null;
        try {
             dynamic t = timer;
             if (t.Run != null && !string.IsNullOrEmpty(t.Run.FilePath)) 
                baseDir = Path.GetDirectoryName(t.Run.FilePath);
        } catch {}
        
        if (baseDir == null) {
            try {
                 dynamic t = timer;
                 if (t.CurrentState != null && t.CurrentState.Run != null && !string.IsNullOrEmpty(t.CurrentState.Run.FilePath)) 
                    baseDir = Path.GetDirectoryName(t.CurrentState.Run.FilePath);
            } catch {} 
        }

        if (!string.IsNullOrEmpty(baseDir))
        {
            var xmlFiles = Directory.GetFiles(baseDir, "*.xml");
            if (xmlFiles.Length > 0)
                settings.Add("Files", true, "Files");

            foreach (var file in xmlFiles)
            {
                string fName = Path.GetFileName(file);
                vars.xmlNames.Add(fName);

                // Map filenames to readable Category names
                string categoryName = fName;
                
                // Add Group for this file (Category)
                string cfgId = "cfg_" + fName;
                bool isDefault = fName.IndexOf("Any", StringComparison.OrdinalIgnoreCase) >= 0; 
                
                settings.Add(cfgId, isDefault, categoryName, "Files");
                
                if (File.Exists(file))
                {
                    try {
                        var doc = new System.Xml.XmlDocument();
                        doc.Load(file);
                        
                        Action<System.Xml.XmlElement, string> parseNode = null;
                        parseNode = (node, parentId) => {
                            string id = node.GetAttribute("id");
                            string name = node.GetAttribute("name");
                            if (!string.IsNullOrEmpty(id))
                            {
                                // Restore automatic transition emoji
                                if (id.Contains(":") && !name.Contains("🔀"))
                                {
                                    name += " 🔀";
                                }

                                // Unique ID for settings: FileName_ID
                                string settingsUniqueId = fName + "_" + id;
                                
                                // Parent is either the file group (cfgId) or another unique ID
                                string settingsParentId = (parentId == null) ? cfgId : (fName + "_" + parentId);
                                
                                settings.Add(settingsUniqueId, true, name, settingsParentId);

                                // Support variable registration from XML IDs
                                if (id.StartsWith("var_"))
                                {
                                     var varMatch = System.Text.RegularExpressions.Regex.Match(id, @"var_(\d+)(?:=(\d+))?");
                                     if (varMatch.Success)
                                     {
                                         int index = int.Parse(varMatch.Groups[1].Value);
                                         if (index >= 0 && index <= 255)
                                         {
                                             // XML variables use the unique ID (filename_id) to avoid collisions
                                             vars.varLabels[index] = settingsUniqueId;
                                             if (varMatch.Groups[2].Success)
                                             {
                                                 vars.varTargets[settingsUniqueId] = int.Parse(varMatch.Groups[2].Value);
                                             }
                                         }
                                     }
                                }
                                
                                foreach (System.Xml.XmlNode child in node.ChildNodes)
                                {
                                    if (child is System.Xml.XmlElement)
                                        parseNode((System.Xml.XmlElement)child, id);
                                }
                            }
                        };
                        
                        foreach (System.Xml.XmlNode child in doc.DocumentElement.ChildNodes)
                        {
                             if (child is System.Xml.XmlElement)
                                parseNode((System.Xml.XmlElement)child, null); 
                        }
                        vars.Log("Loaded scenes from " + fName);
                    } catch (Exception ex) {
                        vars.Log("Failed to load " + fName + ": " + ex.Message);
                    }
                }
            }
        }
    }
    catch (Exception ex)
    {
        vars.Log("Error loading Scene XMLs: " + ex.Message);
    }

    // Parser Settings Table with Duplicate ID Support
    string[,] settingsTable =
    {
        { null, "Categories", "Categories" },
            { "Categories", "Any_percent", "Any%" },
                { "Any_percent", "sc75", "Emerald Moon" },
                { "Any_percent", "sc138", "Otringal" },
                { "Any_percent", "sc109", "Francos Island" },
                { "Any_percent", "sc123", "Undergas" },
                { "Any_percent", "sc105", "Mosquibee Island" },
                { "Any_percent", "sc110", "Island CX" },
                { "Any_percent", "sc88", "Palace" },
                { "Any_percent", "sc80:sc91", "Palace Final Boss Room -> Palace" },

            { "Categories", "Glitchless", "Glitchless" },
                { "Glitchless", "sc46:sc42", "Lighthouse" },
                { "Glitchless", "var_30_diploma", "Magic Diploma" },
                { "Glitchless", "sc92:sc47", "Twinsun" },
                { "Glitchless", "var_169_collected_pearl_incandescent", "Red Pearl" },
                { "Glitchless", "sc17:sc42", "Sewers" },
                { "Glitchless", "sc75", "Moon" },
                { "Glitchless", "sc138", "Otringal" },
                { "Glitchless", "var_31_dmkey_knarta", "Franco Fragment" },
                { "Glitchless", "var_16_dissident_ring", "Dissident Ring" },
                { "Glitchless", "sc123", "Undergas" },
                { "Glitchless", "var_34_dmkey_blafard", "Wannie Fragment" },
                { "Glitchless", "var_33_dmkey_mosqui", "Mosquibee Fragment" },
                { "Glitchless", "sc110", "Island CX" },
                { "Glitchless", "sc110:sc88", "Palace" },
                { "Glitchless", "var_32_dmkey_sup", "Sup Fragment" },
        
            { "Categories", "All achievements", "All achievements 🏆" },
                { "All achievements", "sc75", "Moonlander" },
                { "All achievements", "sc146", "Gazogem secrets" },
                { "All achievements", "sc110", "Go..To..C..X.." },
                { "All achievements", "var_166_clear_weather", "Rainman" },
                { "All achievements", "var_42_heal_dinofly", "Dino-buddy" },
                { "All achievements", "var_109_wizard_tunic", "It's magic!" },
                { "All achievements", "var_161_heal_clam_joe", "Free Joe" },
                { "All achievements", "var_3_sendell_ball", "Ball of Sendell" },
                { "All achievements", "it_STATE_SUPER_JETPACK", "Super Upgrade" },
                { "All achievements", "var_39_protection", "Protection" },
                { "All achievements", "var_18_ferryman_song", "Ferryman Song" },
                { "All achievements", "misc_mine_crane", "Crane Driver" },
                { "All achievements", "misc_kiss_frog", "Prince Charming" },
                { "All achievements", "misc_dog_hop", "Who let the dogs out?" },
                { "All achievements", "misc_on_track", "On track! (may be unstable)" },
                { "All achievements", "var_118_heal_bowler", "I've got your back" },
                { "All achievements", "misc_kill_time_commando", "Time Commando (may be unstable)" },
                { "All achievements", "misc_kash_cow", "Kash Cow" },
                { "All achievements", "misc_op_achievement", "OP" },

        { null, "Items", "Items" },
            { "Items", "var_0_holomap", "Holomap" },
            { "Items", "var_1_magic_ball", "Magic Ball" },
            { "Items", "var_2_dart", "Dart" },
            { "Items", "var_3_sendell_ball", "Sendell Ball" },
            { "Items", "var_4_tunic", "Tunic" },
            { "Items", "var_5_pearl_token", "Pearl / Itinerary Token" },
            { "Items", "var_6_pyramid_key", "Pyramid Key" },
            { "Items", "var_7_wheel", "Wheel" },
            { "Items", "var_8_kash", "Kash" },
            { "Items", "var_9_laser_pistol", "Laser Pistol" },
            { "Items", "var_10_sabre", "Sabre" },
            { "Items", "var_11_glove", "Glove" },
            { "Items", "var_12_protopack", "Protopack" },
            { "Items", "var_13_ferry_ticket", "Ferry Ticket" },
            { "Items", "var_14_meca_penguin", "Meca Penguin" },
            { "Items", "var_15_gazogem", "Gazogem" },
            { "Items", "var_16_dissident_ring", "Dissidents Ring" },
            { "Items", "var_17_acide_gallique", "Acide Gallique" },
            { "Items", "var_18_ferryman_song", "Ferryman Song 🏆" },
            { "Items", "var_19_ring_lightning", "Ring of Lightning" },
            { "Items", "var_20_umbrella", "Umbrella" },
            { "Items", "var_21_gem", "Gem" },
            { "Items", "var_22_conque", "Conque" },
            { "Items", "var_23_blowpipe", "Blowpipe" },
            { "Items", "var_24_road_disk", "Road Disk" },
            { "Items", "var_25_tart_luci", "Tart Luci" },
            { "Items", "var_26_radio", "Radio" },
            { "Items", "var_27_flower", "Flower" },
            { "Items", "var_28_slate", "Slate" },
            { "Items", "var_29_translator", "Translator" },
            { "Items", "var_30_diploma", "Diploma" },
            { "Items", "var_31_dmkey_knarta", "DMKey Knarta" },
            { "Items", "var_32_dmkey_sup", "DMKey Sup" },
            { "Items", "var_33_dmkey_mosqui", "DMKey Mosqui" },
            { "Items", "var_34_dmkey_blafard", "DMKey Blafard" },
            { "Items", "var_35_queen_key", "Queen Key" },
            { "Items", "var_36_pickaxe", "Pickaxe" },
            { "Items", "var_37_burgomaster_key", "Burgomaster Key" },
            { "Items", "var_38_burgomaster_note", "Burgomaster Note" },
            { "Items", "var_39_protection", "Protection 🏆" },
            { "Items", "it_STATE_BLOWTRON", "Blowtron 🏆" },
            { "Items", "it_STATE_COMPLETED_PISTOLASER", "Completed Pistolaser 🏆" },
            { "Items", "it_STATE_SUPER_JETPACK", "Super Jetpack 🏆" },
            
        { null, "Variables", "Variables" },
            { "Variables", "var_40_zoe_status", "Zoe Status" },
            { "Variables", "var_42_heal_dinofly", "Heal Dinofly 🏆" }, 
            { "Variables", "var_161_heal_clam_joe", "Heal Clam Joe 🏆" },
            { "Variables", "var_118_heal_bowler", "Heal Bowler 🏆" }, 
            { "Variables", "var_166_clear_weather", "Clear Weather 🏆" },
            { "Variables", "var_109_wizard_tunic", "Wizard Tunic 🏆" },
            { "Variables", "var_169_collected_pearl_incandescent", "Collected Pearl Incandescent" },

        { null, "MISC", "Miscellaneous" },
            { "MISC", "misc_op_achievement", "OP Achievement 🏆" },
            { "MISC", "misc_mine_crane", "Mine Crane 🏆" }, 
            { "MISC", "misc_kiss_frog", "Kiss Frog 🏆" }, 
            { "MISC", "misc_kill_time_commando", "Kill Time Comando (may be unstable) 🏆" }, 
            { "MISC", "misc_dog_hop", "Dog Hop 🏆" }, 
            { "MISC", "misc_kash_cow", "Kash Cow 🏆" },
            { "MISC", "misc_on_track", "On Track (may be unstable) 🏆" },
    };

    vars.SplitMap = new Dictionary<string, List<string>>();
    var addedSettings = new HashSet<string>();

    for (int i = 0; i < settingsTable.GetLength(0); i++)
    {
        var parent = settingsTable[i, 0];
        var id     = settingsTable[i, 1];
        var desc   = settingsTable[i, 2];

        if (id.Contains(":"))
        {
            desc += " 🔀";
        }

        // Logic to allow duplicates:
        // If ID is already in settings, or we just want to ensure uniqueness for categories
        // We prefix with parent ID.
        
        string effectiveId = id;

        // Check if this ID is already registered or if it's a child of a Category (non-null parent)
        // Simple heuristic: If settings already has this KEY, we MUST make it unique.
        // Also map it.
        
        if (addedSettings.Contains(id))
        {
             // Collision! make unique using parent
             if (parent != null) 
                 effectiveId = parent + "_" + id;
             else 
                 effectiveId = id + "_dup"; // Should not happen for roots
        }
        else
        {
            // Even if not colliding yet, if we are inside "Any_percent" or "All achievements", 
            // the user MIGHT add the same ID later. 
            // To be safe, if parent is one of the known categories, we should prefix? 
            // OR just rely on the collision check?
            // Relying on collision check depends on ORDER. 
            // Any_percent sc115 comes first -> gets "sc115".
            // All_achievements sc115 comes second -> gets "All achievements_sc115".
            // This is messy. 
            
            // BETTER: If parent is NOT null and NOT "Items"/"MISC"/ "Categories", likely a specific category.
            // Let's explicitly check known defaults? 
            if (parent == "Any_percent" || parent == "All achievements")
            {
                 effectiveId = parent + "_" + id;
            }
        }
        
        settings.Add(effectiveId, true, desc, parent);
        addedSettings.Add(effectiveId);
        
        // Map original ID to effective ID for logic checking
        if (!vars.SplitMap.ContainsKey(id))
            vars.SplitMap[id] = new List<string>();
        
        vars.SplitMap[id].Add(effectiveId);
    }
    
    // Dynamic Variable Labels Parsing (e.g. var_166 -> Index 166)
    for (int i = 0; i < settingsTable.GetLength(0); i++)
    {
        string id = settingsTable[i, 1];
        if (id != null && id.StartsWith("var_"))
        {
             var match = System.Text.RegularExpressions.Regex.Match(id, @"var_(\d+)(?:=(\d+))?");
             if (match.Success)
             {
                 int index = int.Parse(match.Groups[1].Value);
                 if (index >= 0 && index <= 255)
                 {
                     vars.varLabels[index] = id;
                     if (match.Groups[2].Success)
                     {
                         vars.varTargets[id] = int.Parse(match.Groups[2].Value);
                     }
                 }
             }
        }
    }

    vars.CompletedSplits = new HashSet<string>();
}

// -------- INIT --------

init
{
    vars.CompletedSplits.Clear();
    vars.Watchers = new MemoryWatcherList();

    // User requested explicit ProcessName check
    var procName = memory.ProcessName.ToLower();
    vars.Log("procName: " + procName);

    IntPtr baseAddr = IntPtr.Zero;
    int idx = 0; 

    if (procName.Contains("tlba2c"))
    {
        // Classic: Use module base
        var classicModule = modules.FirstOrDefault(m => m.ModuleName.ToLower().Contains("tlba2c"));
        baseAddr = (classicModule != null) ? classicModule.BaseAddress : modules.First().BaseAddress;
        idx = 0;
        vars.Log("Classic version detected (" + (classicModule != null ? classicModule.ModuleName : "TLBA2C") + "). Base: 0x" + baseAddr.ToString("X"));
    }
    else if (procName.Contains("dosbox"))
    {
        // DOSBox: User requested NO base address addition.
        // Reading absolute address 0x1D4A380. 
        int dosBoxBaseValue = memory.ReadValue<int>((IntPtr)0x1D4A380);
        
        if (dosBoxBaseValue == 0)
        {
            throw new Exception("DOSBox RAM pointer not found (yet). Retrying...");
        }
        
        baseAddr = (IntPtr)dosBoxBaseValue;
        idx = 1;
        vars.Log("DOSBox detected. Emulated RAM ptr: 0x" + dosBoxBaseValue.ToString("X"));
    }
    else if (procName.Contains("twinsen") )
    {
        // Win95: Original version, use module base
        var win95Module = modules.FirstOrDefault(m => m.ModuleName.ToLower().Contains("twinsen"));
        baseAddr = (win95Module != null) ? win95Module.BaseAddress : modules.First().BaseAddress;
        idx = 2;
        vars.Log("Win95 version detected (Name: " + procName + ", Module: " + (win95Module != null ? win95Module.ModuleName : "Default") + "). Base: 0x" + baseAddr.ToString("X"));
    }
    else
    {
        vars.Log("Unknown process: " + procName);
    }

    Func<int, DeepPointer> GetPtr = (offset) => {
         return new DeepPointer(baseAddr + offset);
    };   
    
    // Dictionary of offsets [Classic, DOS, Win95]
    var offsets = new Dictionary<string, int[]> {
        { "scene",              new[] { 0x47FEC8, 0x267C7C, 0x97EF0  } },
        { "vars_base",          new[] { 0x481E60, 0x269C10, 0x99E84  } },
        { "kashes",             new[] { 0x482060, 0x269E14, 0x9A088  } },
        // var game
        { "in_ending_cutscene", new[] { 0x481F9A, 0x269D4A, 0x99FBE  } }, // var_157
        { "blowtron",           new[] { 0x4A2992, 0x28A840, 0xBAAB4  } },
        { "pistolaser",         new[] { 0x4A285E, 0x28A70C, 0xBA980  } },
        { "super_jetpack",      new[] { 0x4A28A0, 0x28A74E, 0xBA9C2  } },
        // var scenes 
        { "mine_crane",         new[] { 0x481E10, 0x269BC0, 0x99E34  } },    
        // var track
        { "track",              new[] { 0x48235C, 0x26A110, 0x9A384  } },
        // unknown
        { "kill_time_commando", new[] { 0x4BD2C2, 0x26B268, 0x9B4DC  } }, // 139 & 65535 -> may be unstable
        { "on_track",           new[] { 0x47F6D4, 0x39FA50, 0x1CF934 } } // may be unstable
    };

    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["scene"][idx])) { Name = "scene" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["in_ending_cutscene"][idx])) { Name = "in_ending_cutscene" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["kashes"][idx])) { Name = "kashes" });

    // Variables - Dynamically added ushorts from vars.varLabels
    foreach (var pair in vars.varLabels)
    {
        vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["vars_base"][idx] + (pair.Key * 2))) { Name = pair.Value });
    }

    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["blowtron"][idx])) { Name = "blowtron" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["pistolaser"][idx])) { Name = "pistolaser" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["super_jetpack"][idx])) { Name = "super_jetpack" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["mine_crane"][idx])) { Name = "mine_crane" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["kill_time_commando"][idx])) { Name = "kill_time_commando" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["on_track"][idx])) { Name = "on_track" });
    vars.Watchers.Add(new MemoryWatcher<ushort>(GetPtr(offsets["track"][idx])) { Name = "track" });
}

// -------- UPDATE --------

update
{
    vars.Watchers.UpdateAll(game);

    var watchers = vars.Watchers;

    if (watchers["scene"].Current != watchers["scene"].Old)
        vars.Log("Scene: " + watchers["scene"].Current);

    if (watchers["in_ending_cutscene"].Current != watchers["in_ending_cutscene"].Old)
        vars.Log("in_ending_cutscene: " + watchers["in_ending_cutscene"].Current);
}

// -------- START --------

start
{
    var watchers = vars.Watchers;
    if (watchers["scene"].Old == 65535 && watchers["scene"].Current == 0)
    {
        vars.CompletedSplits.Clear();
        vars.Log("Start");
        return true;
    }
}

reset
{
    var watchers = vars.Watchers;
    if (watchers["scene"].Old == 65535 && watchers["scene"].Current == 0)
    {
        vars.Log("Reset");
        return true;
    }
}

// -------- SPLIT --------

split
{
    var watchers = vars.Watchers;

    // Helper to check if ANY setting associated with this split key is enabled
    Func<string, bool> IsSplitEnabled = (key) => {
        // Direct setting check
        if (settings.ContainsKey(key) && settings[key]) return true;

        // Map check (for duplicates/categories)
        if (vars.SplitMap != null && vars.SplitMap.ContainsKey(key))
        {
             foreach (string mappedKey in vars.SplitMap[key])
             {
                 if (settings.ContainsKey(mappedKey) && settings[mappedKey])
                     return true;
             }
        }
        return false;
    };

    // SCENE SPLITS
    if (watchers["scene"].Old != watchers["scene"].Current)
    {
        string scKey = "sc" + watchers["scene"].Current;
        if (!vars.CompletedSplits.Contains(scKey))
        {
             // Check standard or XML loaded 
             bool shouldSplit = false;
             if (IsSplitEnabled(scKey)) shouldSplit = true;
             
             // Keep legacy XML check for backward compat if needed, 
             // but SplitMap should handle it if parsing is correct?
             // The user REVERTED to manual XML parsing in Step 72, which blindly Adds to settings.
             // We need to keep XML check logic OR ensure XML parsing also populates SplitMap.
             // The user's XML parsing in Step 73 blindly adds `settings.Add(settingsUniqueId...`.
             // It does NOT populate SplitMap.
             // So we must ALSO assume the XML pattern: `FileName_ID`
             
             if (!shouldSplit && vars.xmlNames != null)
             {
                 foreach (string fName in vars.xmlNames)
                 {
                     string cfgKey = "cfg_" + fName;
                     if (settings.ContainsKey(cfgKey) && settings[cfgKey])
                     {
                         string fullKey = fName + "_" + scKey;
                         if (settings.ContainsKey(fullKey) && settings[fullKey])
                         {
                             shouldSplit = true;
                             break;
                         }
                     }
                 }
             }

             if (shouldSplit)
             {
                 vars.CompletedSplits.Add(scKey);
                 vars.Log("Split Scene: " + scKey);
                 return true;
             }
        }

        // Transition Splits (scOld:scNew)
        string transitionKey = "sc" + watchers["scene"].Old + ":sc" + watchers["scene"].Current;
        if (!vars.CompletedSplits.Contains(transitionKey))
        {
             bool shouldSplit = false;
             if (IsSplitEnabled(transitionKey)) shouldSplit = true;

             if (!shouldSplit && vars.xmlNames != null)
             {
                 foreach (string fName in vars.xmlNames)
                 {
                     string cfgKey = "cfg_" + fName;
                     if (settings.ContainsKey(cfgKey) && settings[cfgKey])
                     {
                         string fullKey = fName + "_" + transitionKey;
                         if (settings.ContainsKey(fullKey) && settings[fullKey])
                         {
                             shouldSplit = true;
                             break;
                         }
                     }
                 }
             }

             if (shouldSplit)
             {
                 vars.CompletedSplits.Add(transitionKey);
                 vars.Log("Split Transition: " + transitionKey);
                 return true;
             }
        }
    }


    // Items not in flags
    if (!vars.CompletedSplits.Contains("it_STATE_BLOWTRON") && IsSplitEnabled("it_STATE_BLOWTRON") && watchers["blowtron"].Current > 0)
    {
        vars.CompletedSplits.Add("it_STATE_BLOWTRON");
        vars.Log("Split: Blowtron");
        return true;
    }
    if (!vars.CompletedSplits.Contains("it_STATE_COMPLETED_PISTOLASER") && IsSplitEnabled("it_STATE_COMPLETED_PISTOLASER") && watchers["pistolaser"].Current > 1)
    {
        vars.CompletedSplits.Add("it_STATE_COMPLETED_PISTOLASER");
        vars.Log("Split: Pistolaser");
        return true;
    }
    if (!vars.CompletedSplits.Contains("it_STATE_SUPER_JETPACK") && IsSplitEnabled("it_STATE_SUPER_JETPACK") && watchers["super_jetpack"].Current > 0)
    {
        vars.CompletedSplits.Add("it_STATE_SUPER_JETPACK");
        vars.Log("Split: Super Jetpack");
        return true;
    }

    // VARIABLE SPLITS
    foreach (var pair in vars.varLabels)
    {
        string key = pair.Value;
        if (!vars.CompletedSplits.Contains(key) && IsSplitEnabled(key))
        {
             int target = 0;
             bool hasTarget = vars.varTargets.TryGetValue(key, out target);
             bool condition = hasTarget ? (watchers[key].Current == target) : (watchers[key].Current > 0);

             if (condition)
             {
                 vars.CompletedSplits.Add(key);
                 vars.Log("Split Var: " + key + (hasTarget ? " (target: " + target + ")" : ""));
                 return true;
             }
        }
    }

    // MISC SPLITS
    if (!vars.CompletedSplits.Contains("misc_kash_cow") && IsSplitEnabled("misc_kash_cow") && watchers["kashes"].Current > 499)
    {
        vars.CompletedSplits.Add("misc_kash_cow");
        vars.Log("Split: Kash Cow");
        return true;
    }

    // Scene-specific misc
    if (!vars.CompletedSplits.Contains("misc_mine_crane") && IsSplitEnabled("misc_mine_crane") && watchers["scene"].Current == 100 && watchers["mine_crane"].Current == 256)
    {
        vars.CompletedSplits.Add("misc_mine_crane");
        vars.Log("Split: Mine Crane");
        return true;
    }
    if (!vars.CompletedSplits.Contains("misc_kiss_frog") && IsSplitEnabled("misc_kiss_frog") && watchers["scene"].Current == 96 && watchers["track"].Current == 10)
    {
        vars.CompletedSplits.Add("misc_kiss_frog");
        vars.Log("Split: Kiss Frog");
        return true;
    }
    if (!vars.CompletedSplits.Contains("misc_kill_time_commando") && IsSplitEnabled("misc_kill_time_commando") && watchers["scene"].Current == 159 && (watchers["kill_time_commando"].Current == 65535 || watchers["kill_time_commando"].Current == 139))
    {
        vars.CompletedSplits.Add("misc_kill_time_commando");
        vars.Log("Split: Kill Time Commando");
        return true;
    }
    if (!vars.CompletedSplits.Contains("misc_dog_hop") && IsSplitEnabled("misc_dog_hop") && watchers["scene"].Current == 90 && watchers["track"].Current == 40)
    {
        vars.CompletedSplits.Add("misc_dog_hop");
        vars.Log("Split: Dog Hop");
        return true;
    }
    if (!vars.CompletedSplits.Contains("misc_on_track") && IsSplitEnabled("misc_on_track") && watchers["scene"].Current == 57 && watchers["on_track"].Current == 1)
    {
        vars.CompletedSplits.Add("misc_on_track");
        vars.Log("Split: On Track");
        return true;
    }

    // OP Achievement
    if (!vars.CompletedSplits.Contains("misc_op_achievement") && IsSplitEnabled("misc_op_achievement"))
    {
         if (watchers["var_1_magic_ball"].Current > 0 &&
             watchers["blowtron"].Current > 0 &&
             watchers["super_jetpack"].Current > 0 &&
             watchers["pistolaser"].Current > 1)
         {
             vars.CompletedSplits.Add("misc_op_achievement");
             vars.Log("Split: OP");
             return true;
         }
    }

    // END
    if (watchers["in_ending_cutscene"].Current == 1)
    {
        vars.Log("Split Action: End");
        return true;
    }

    return false;
}

// -------- EXIT --------

exit
{
    vars.CompletedSplits.Clear();
}
