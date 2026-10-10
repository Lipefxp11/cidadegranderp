#if defined _DOF3_included
	#endinput
#endif
#define _DOF3_included

#include <a_samp>

#define Stock2:%0(%1) stock %0(%1)

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

/*
 * This is a new version of the INI script Double-O-Files.
 * However, it's has completely been rewritten and has now a much better performance.
 * There is also the support for sections in the INI file. (But there is no support for comments.)
 * Double-O-Files 2 is compatible with DUDB, DINI, Double-O-Files and possibly y_ini since it
 * can handle sections and entry of the format "key = value", not only "key=value".
 * The number of spaces between the equal sign and key and value can actually be arbitrary.
 * I've added some comments below. You may see that I've mentioned the big-O-notation,
 * 'n' always Entries.Count.
 * Double-O-Files 2 should also be useful for Russian letter because I'm using
 * the functions fgetchar and fputchar to write and read the files.
 *
 * There is another new feature which has been inspired by ZCMD and y_ini:
 * The OnParseFile callbacks. To learn more about it, read the description in
 * the SA-MP forums if you haven't already.
 * THE END
 */

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

/*
native DOF3_SetFile(file[]);
native DOF3_LoadFile();
native DOF3_SaveFile();
native DOF3_ParseFile(file[],extraid,bool:callback=true);
native DOF3_ReparseFile(file[],extraid,bool:callback=true);
native DOF3_WriteFile();
native DOF3_PrintFile(comment[]="");
native DOF3_GetString(file[],key[],tag[]="");
native DOF3_GetStringEx(file[],key[],result[],size,tag[]="");
native Float:DOF3_GetFloat(file[],key[]);
native DOF3_GetInt(file[],key[],tag[]="");
native DOF3_GetHex(file[],key[],tag[]="");
native DOF3_GetBin(file[],key[],tag[]="");
native bool:DOF3_GetBool(file[],key[],tag[]="");
native DOF3_SetString(file[],key[],value[],tag[]="");
native DOF3_SetFloat(file[],key[],Float:value);
native DOF3_SetInt(file[],key[],value,tag[]="");
native DOF3_SetHex(file[],key[],value,tag[]="");
native DOF3_SetBin(file[],key[],value,tag[]="");
native DOF3_SetBool(file[],key[],bool:value,tag[]="");
native DOF3_IsSet(file[],key[],tag[]="");
native DOF3_Unset(file[],key[],tag[]="");
native DOF3_FileExists(file[]);
native DOF3_RemoveFile(file[]);
native DOF3_CreateFile(file[],password[]="");
native DOF3_RenameFile(oldfile[],newfile[]);
native DOF3_RenameKey(file[],oldkey[],newkey[],tag[]="");
native DOF3_CopyFile(filetocopy[],newfile[]);
native DOF3_CheckLogin(file[],password[]);
native DOF3_File(user[]);
native DOF3_ParseInt();
native DOF3_ParseFloat();
native DOF3_ParseBool();
native DOF3_ParseBin();
native DOF3_ParseHex();
native DOF3_SetUTF8(bool:set);
native bool:DOF3_GetUTF8();
native DOF3_GetFile();
native DOF3_MakeBackup(file[]);
native DOF3_RemoveSection (file [], tag []);
native DOF3_SectionExists (file [], tag []);
native DOF3_SortSection (file [], tag [], bool: ignorecase = true, bool: ascending = true);
native DOF3_SortAllSections (file [], bool: ignorecase = true, bool: ascending = true);
native DOF3_SetCaseSensitivity (bool: set);
native DOF3_GetCaseSensitivity ();
*/

#define DOF3_TagExists  DOF3_SectionExists
#define DOF3_RemoveTag  DOF3_RemoveSection

// OnParseFile <Tag><Key>(extraid, value [])
// OnParseFile <><Key>(extraid, value [])
// OnDefaultParseFile (extraid, value [], key [], tag [], file [])

// The arguments of your OnParseFile functions may have arbitrary names but must be an integer followed by a string.
// Function must return a value.
#define OnParseFile<%0><%1>(%2) \
	forward _OnParseFile_%0_%1 (extraid, value []); \
	public _OnParseFile_%0_%1 (extraid, value []) \
	    return __OnParseFile_%0_%1 (extraid, (value [0] == '\1' && value [1] == '\0') ? ("") : value); \
	stock __OnParseFile_%0_%1 (%2)

// Also here: The argument names may be arbitrary but must be an integer followed by 4 strings.
// Function must return a value.
#define OnDefaultParseFile(%0) \
	forward _OnDefaultParseFile (extraid, value [], key [], tag [], file []); \
	public _OnDefaultParseFile (extraid, value [], key [], tag [], file []) \
	    return __OnDefaultParseFile (extraid, (value [0] == '\1' && value [1] == '\0') ? ("") : value, key, (tag [0] == '\1' && tag [1] == '\0') ? ("") : tag, file); \
	stock __OnDefaultParseFile (%0)

#define DOF3_ParseBool() \
	(strval (value) || (value [0] && !strcmp (value, "true", true)))

#define DOF3_ParseInt() \
	(strval (value))

#define DOF3_ParseFloat() \
	(floatstr (value))

#define DOF3_ParseBin() \
	(DOF3_strbin (value))

#define DOF3_ParseHex() \
	(DOF3_strhex (value))

#define DOF3_LoadFile() \
	DOF3_ParseFile (CurrentFile, -1, false)

#define DOF3_SaveFile \
	DOF3_WriteFile

#define DOF3_FileExists \
	fexist

#define Sections. \
	Sections_

#define Entries. \
	Entries_

#define DOF3:: \
	DOF3_
	
#if !defined private
	#define private 		static stock
#endif
	
#pragma dynamic 65536

/*
#define MAX_SECTION_TAG        (32)
#define MAX_LINE_SIZE       (128)
#define MAX_SECTIONS            (32)
#define MAX_ENTRIES         (256)
#define MAX_FILE_SIZE       (64)

#define USER_FILE_PATH 		"Users/%s.ini"
*/

// The maximum length of the name of a tag.
#if !defined MAX_SECTION_TAG
	#define MAX_SECTION_TAG    	(32)
#endif

// The maximum length of a line (including key and value).
#if !defined MAX_LINE_SIZE
	#define MAX_LINE_SIZE       (128)
#endif

// The maximum number of sections which can be handled. Be careful: MUST NOT be higher than 255.
#if !defined MAX_SECTIONS
	#define MAX_SECTIONS       	(32)
#endif

// The maximum number of entries which can be loaded into the cache.
#if !defined MAX_ENTRIES
	#define MAX_ENTRIES         (256)
#endif

// The maximum length of the name of a file.
#if !defined MAX_FILE_SIZE
	#define MAX_FILE_SIZE       (64)
#endif

/*
If PACK_CONTENT == true tag names and lines (key + value) will get stored in cache as packed strings.
The result is less memory usage. However, you won't be able to use special characters like russian or chinese ones.
*/
#if !defined PACK_CONTENT
	#define PACK_CONTENT        (false)
#endif

#define INVALID_ENTRY           (-1)
#define INVALID_SECTION         (-1)

// Do you want to emulate DUDB?
#if !defined DUDB_CONVERT && 0 // Change to 1 to enable.
	#define DUDB_CONVERT
#endif

#if !defined USER_FILE_PATH
	#if defined DUDB_CONVERT
		#define USER_FILE_PATH 	"%s.dudb.sav"
	#else
	    #define USER_FILE_PATH 	"%s.ini"
	#endif
#endif

#if !defined USER_PW_HASH_KEY
    #if defined DUDB_CONVERT
		#define USER_PW_HASH_KEY "password_hash"
	#else
	    #define USER_PW_HASH_KEY "password"
	#endif
#endif
	

// Do you want to emulate DINI?
#if !defined DINI_CONVERT && 0 // Change to 1 to enable.
	#define DINI_CONVERT
#endif

/*
#if MAX_SECTIONS >= 256
	#error MAX_SECTIONS must not be greater than 255.
#endif
*/

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

private
	bool: UseUTF8 = PACK_CONTENT,
	bool: CaseSensitive = false,
	CurrentFile [MAX_FILE_SIZE],
	bool: FileChanged,
	Sections.FirstEntry [MAX_SECTIONS] = {INVALID_ENTRY, ...},
	Sections.LastEntry [MAX_SECTIONS] = {INVALID_ENTRY, ...},
	Sections.Count,
#if PACK_CONTENT == true
	Sections.Tag [MAX_SECTIONS][MAX_SECTION_TAG char],
	Entries.Line [MAX_ENTRIES][MAX_LINE_SIZE char],
	Entries.Tag [MAX_ENTRIES][MAX_SECTION_TAG char],
#else
	Sections.Tag [MAX_SECTIONS][MAX_SECTION_TAG],
    Entries.Line [MAX_ENTRIES][MAX_LINE_SIZE],
	Entries.Tag [MAX_ENTRIES][MAX_SECTION_TAG],
#endif
#if MAX_SECTIONS >= 256
	Entries.Section [MAX_ENTRIES],
#else
	Entries.Section [MAX_ENTRIES char],
#endif
	Entries.NextEntry [MAX_ENTRIES] = {INVALID_ENTRY, ...},
	Entries.PreviousEntry [MAX_ENTRIES] = {INVALID_ENTRY, ...},
	Entries.Count,
	SortedEntryList [MAX_ENTRIES][2]; // Index 0: Hashcode, Index 1: EntryID

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

DOF3::Exit ()
	DOF3::WriteFile ();

stock DOF3::SetUTF8 (bool: set)
	UseUTF8 = set;

stock bool: DOF3::GetUTF8 ()
	return UseUTF8;

stock bool: DOF3::SetCaseSensitivity (bool: set)
	CaseSensitive = set;
	
stock bool: DOF3::GetCaseSensitivity ()
	return CaseSensitive;

stock DOF3::SetFile (const file [])
	DOF3::strcpy (CurrentFile, file);

stock DOF3::GetFile ()
	return CurrentFile;

stock DOF3::CreateFile (const file [], const password [] = "")
{
	if (!DOF3::FileExists (file))
	{
        new File: f = fopen (file, io_append);
        
		if (fclose (f))
		{
			if (password [0])
		    	return DOF3::SetInt (file, USER_PW_HASH_KEY, DOF3::num_hash (password));
			return 1;
		}
	}
	return 0;
}
stock DOF3::RenameFile (const oldfile [], const newfile [])
{
	if (!DOF3::FileExists (newfile))
	{
	    // If 'CurrentFile' is 'oldfile', write it if it has been changed.
		if (CurrentFile [0] && !strcmp (CurrentFile, oldfile) && FileChanged)
			DOF3::WriteFile ();
		else if (!DOF3::ParseFile (oldfile, -1, false)) // Otherwise parse 'oldfile'.
		    return 0;
		    
		DOF3::SetFile (newfile);
		if (DOF3::WriteFile ())
		    return fremove (oldfile);
	}
	return 0;
}

stock DOF3::CopyFile (const filetocopy [], const newfile [])
{
    if (!DOF3::FileExists (newfile))
	{
	    if (CurrentFile [0] && !strcmp (CurrentFile, filetocopy) && FileChanged)
			DOF3::WriteFile ();
		else if(!DOF3::ParseFile (filetocopy, -1, false))
		    return 0;
		    
		DOF3::SetFile (newfile);
		return DOF3::WriteFile ();
	}
	return 0;
}

stock DOF3::RemoveFile (const file [])
{
	if (file [0])
	{
	    if (CurrentFile [0] && !strcmp (CurrentFile, file))
	        CurrentFile [0] = '\0';
		return fremove (file);
	}
	return 0;
}

stock DOF3::MakeBackup (const file [])
{
    new
        year,
		month,
		day,
		hour,
		minute,
		second,
		backupfile [MAX_FILE_SIZE];

    getdate (year, month, day);
    gettime (hour, minute, second);
    format (backupfile, sizeof (backupfile), "%s.%02d_%02d_%02d.%02d_%02d_%02d_%02d.bak", CurrentFile, month, day, year, hour, minute, second, GetTickCount ());
    return DOF3::CopyFile (CurrentFile, backupfile);
}

stock bool: DOF3::SectionExists (const file [], const tag [])
{
    if (file [0]) // You can't remove the empty Sections.
	{
	    if (!tag [0])
	        return true; // Emptry section always exists. In every file.

        if (!CurrentFile [0] || strcmp (CurrentFile, file)) // No file in buffer or the file you want to read from is not the file in the buffer.
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return false;

	#if PACK_CONTENT == true
		new buf [MAX_SECTION_TAG];
	#endif
	
    	for (new i = 1; i < Sections.Count; ++i)
    	{
    	#if PACK_CONTENT == true
    	    strunpack (buf, Sections.Tag [i]);
	        if (!strcmp (buf, tag, !CaseSensitive))
		        return true;
		#else
		    if (!strcmp (Sections.Tag [i], tag, !CaseSensitive))
		        return true;
		#endif
    	}
	}
	return false;
}

stock DOF3::RemoveSection (const file [], const tag [])
{
	// Removes tag 'tag' with all it's entries.
	if (file [0] && tag [0]) // You can't remove the empty Sections.
	{
    	if (!CurrentFile [0] || strcmp (CurrentFile, file)) // No file in buffer or the file you want to read from is not the file in the buffer.
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

		new
		#if PACK_CONTENT == true
		    line [MAX_LINE_SIZE],
		    buf [MAX_SECTION_TAG],
		#endif
			section = INVALID_SECTION,
			entry,
			key [MAX_KEY_SIZE];

	    for (new i = 1; i < Sections.Count; ++i)
	    {
		#if PACK_CONTENT == true
	        strunpack (buf, Sections.Tag [i]);
	        if (!strcmp (buf, tag, !CaseSensitive))
	        {
	            section = i;
	            break;
	        }
		#else
		    if (!strcmp (Sections.Tag [i], tag, !CaseSensitive))
	        {
	            section = i;
	            break;
	        }
		#endif
	    }

		if (section != INVALID_SECTION)
		{
			entry = Sections.FirstEntry [section];
			while (entry != INVALID_ENTRY)
			{
			    // Remove all entries under the current Sections.
		    #if PACK_CONTENT == true
		    	strunpack (line, Entries.Line [entry]);
			    DOF3::ParseLine (line, key, buf);
			#else
			    DOF3::ParseLine (Entries.Line [entry], key, buf);
			#endif
			    DOF3::Unset (file, key, tag);
				entry = Entries.NextEntry [entry];
			}

		    // Move the last tag to the position of the current tag. Creates a little mess.
		    --Sections.Count;
		    Sections.Tag [section] = Sections.Tag [Sections.Count];
		    Sections.FirstEntry [section] = Sections.FirstEntry [Sections.Count];
		    Sections.LastEntry [section] = Sections.LastEntry [Sections.Count];

			// Adjust the tag IDs of the entries.
		    entry = Sections.FirstEntry [section];
		    while (entry != INVALID_ENTRY)
		    {
			#if MAX_SECTIONS >= 256
				Entries.Section [entry] = section;
			#else
		        Entries.Section {entry} = section;
			#endif
		        entry = Entries.NextEntry [entry];
		    }
		    FileChanged = true;
		    return 1;
		}
	}
	return 0;
}

private DOF3::SearchEntry (const key [], const tag [], keybuf [], valbuf [], &pos, keybufsize = sizeof (keybuf), valbufsize = sizeof (valbuf))
{
	if (key [0] && Entries.Count)
	{
	    new
	        entry = INVALID_ENTRY,
	        l,
	        m,
	        r,
	        h,
		#if PACK_CONTENT == true
	        line [MAX_LINE_SIZE],
	        buf [MAX_SECTION_TAG],
		#endif
	        i;

        h = DOF3::HashKey (key);
		l = 0;
		r = Entries.Count - 1;

		/*
		 * Binary search in a sorted list of entries in O(log n) time. This algorithm makes for example with 256 elements a maximum of ~8 steps until the entry is found if it exists.
		 * A sequential search would take up to 256 steps. That was the case in the first Double-O-Files script.
		 */
		while (l <= r)
		{
		    if ((r - l) < 2)
		    {
		        if (h == SortedEntryList [l][0])
		        {
		            m = l;
			        entry = SortedEntryList [l][1];
				}
				else if (r > l && h == SortedEntryList [r][0])
				{
				    m = r;
				    entry = SortedEntryList [r][1];
				}
		        break;
		    }
		    else
		    {
		        m = l + (r - l) / 2;
			    if (h == SortedEntryList [m][0])
			    {
			        entry = SortedEntryList [m][1];
			        break;
			    }
			    else if (h > SortedEntryList [m][0])
					l = m + 1;
				else
				    r = m - 1;
			}
		}

		// Candidate found?
		if (entry != INVALID_ENTRY)
		{
			// Check if it's the entry we want.
  		#if PACK_CONTENT == true
			strunpack (line, Entries.Line [entry]);
			DOF3::ParseLine (line, keybuf, valbuf, keybufsize, valbufsize);
		    strunpack (buf, Entries.Tag [entry]);
			if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !buf [0]) || (tag [0] && buf [0] && !strcmp (tag, buf, !CaseSensitive))))
		#else
			DOF3::ParseLine (Entries.Line [entry], keybuf, valbuf, keybufsize, valbufsize);
		    if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !Entries.Tag [entry][0]) || (tag [0] && Entries.Tag [entry][0] && !strcmp (tag, Entries.Tag [entry], !CaseSensitive))))
		#endif
			    return (pos = m, entry);
			else
			{
			    // If not, look left and right in the list for entries with the same hash code. This can be collisions or entries with the same key from another section.
			    for (i = m - 1; i >= 0 && h == SortedEntryList [i][0]; --i)
			    {
			        entry = SortedEntryList [i][1];
			 	#if PACK_CONTENT == true
					strunpack (line, Entries.Line [entry]);
					DOF3::ParseLine (line, keybuf, valbuf, keybufsize, valbufsize);
				    strunpack (buf, Entries.Tag [entry]);
					if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !buf [0]) || (tag [0] && buf [0] && !strcmp (tag, buf, !CaseSensitive))))
				#else
					DOF3::ParseLine (Entries.Line [entry], keybuf, valbuf, keybufsize, valbufsize);
				    if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !Entries.Tag [entry][0]) || (tag [0] && Entries.Tag [entry][0] && !strcmp (tag, Entries.Tag [entry], !CaseSensitive))))
				#endif
					    return (pos = i, entry);
			    }

			    for (i = m + 1; i < Entries.Count && h == SortedEntryList [i][0]; ++i)
			    {
			        entry = SortedEntryList [i][1];
			 	#if PACK_CONTENT == true
					strunpack (line, Entries.Line [entry]);
					DOF3::ParseLine (line, keybuf, valbuf, keybufsize, valbufsize);
				    strunpack (buf, Entries.Tag [entry]);
					if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !buf [0]) || (tag [0] && buf [0] && !strcmp (tag, buf, !CaseSensitive))))
				#else
					DOF3::ParseLine (Entries.Line [entry], keybuf, valbuf, keybufsize, valbufsize);
				    if (!strcmp (keybuf, key, !CaseSensitive) && ((!tag [0] && !Entries.Tag [entry][0]) || (tag [0] && Entries.Tag [entry][0] && !strcmp (tag, Entries.Tag [entry], !CaseSensitive))))
				#endif
					    return (pos = i, entry);
			    }
			}
		}
	}
	
	keybuf [0] = valbuf [0] = '\0';
	return INVALID_ENTRY;
}

stock DOF3::SetString (const file [], const key [], const value [], const tag [] = "")
{
    if (file [0] && key [0])
	{
	    new
	        entry,
	        pos,
	        section = INVALID_SECTION,
	        keybuf [MAX_LINE_SIZE],
	        valbuf [MAX_LINE_SIZE],
		#if PACK_CONTENT == true
	        buf [MAX_SECTION_TAG],
	        line [MAX_LINE_SIZE],
		#endif
			i;

        if (!CurrentFile [0] || strcmp (CurrentFile, file)) // No file in buffer or the file you want to read from is not the file in the buffer.
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

        entry = DOF3::SearchEntry (key, tag, keybuf, valbuf, pos);

        // If the entry has been found, just change it's content.
        if (entry != INVALID_ENTRY)
		{
		    FileChanged = true;
		#if PACK_CONTENT == true
			format (line, sizeof (line), "%s = %s", key, value [0] ? value : ("(null)"));
		    return strpack (Entries.Line [entry], line);
		#else
			format (Entries.Line [entry], sizeof (Entries.Line []), "%s = %s", key, value [0] ? value : ("(null)"));
			return 1;
		#endif
        }

		if (Entries.Count >= MAX_ENTRIES)
		    return 0;

		// Search for the section where the entry belongs.
		if (!tag [0])
		    section = 0;
		else
		{
			for (i = 1; i < Sections.Count; ++i)
			{
			#if PACK_CONTENT == true
			    strunpack (buf, Sections.Tag [i]);
			    if (buf [0] && !strcmp (tag, buf, !CaseSensitive))
			    {
			        section = i;
			        break;
			    }
			#else
			    if (Sections.Tag [i][0] && !strcmp (tag, Sections.Tag [i], !CaseSensitive))
			    {
			        section = i;
			        break;
			    }
			#endif
			}
		}

		// Section we want does not exist, create new one if possible.
		if (section == INVALID_SECTION)
		{
		    if (Sections.Count >= MAX_SECTIONS)
		        return 0;

		    section = Sections.Count++;
	    #if PACK_CONTENT == true
			strpack (Sections.Tag [section], tag);
		#else
		    DOF3::strcpy (Sections.Tag [section], tag);
		#endif
			Sections.FirstEntry [section] = Sections.LastEntry [section] = INVALID_ENTRY;
		}

		// Add the entry to the section. Section's content is defined by a linear two way list.
	#if PACK_CONTENT == true
		format (line, sizeof (line), "%s = %s", key, value [0] ? value : ("(null)"));
		strpack (Entries.Line [Entries.Count], line);
	#else
	    format (Entries.Line [Entries.Count], sizeof (Entries.Line []), "%s = %s", key, value [0] ? value : ("(null)"));
	#endif
		Entries.Tag [Entries.Count] = Sections.Tag [section];
    #if MAX_SECTIONS >= 256
		Entries.Section [Entries.Count] = section;
	#else
	    Entries.Section {Entries.Count} = section;
	#endif
		Entries.NextEntry [Entries.Count] = INVALID_ENTRY;

		// Add entry to sorted list of entries and move to right correct position in O(n) time.
		SortedEntryList [Entries.Count][0] = DOF3::HashKey (key);
		SortedEntryList [Entries.Count][1] = Entries.Count;
		i = Entries.Count - 1;
		while (i >= 0 && SortedEntryList [i][0] > SortedEntryList [i + 1][0])
		{
		    DOF3::SwapSortedEntries (SortedEntryList [i], SortedEntryList [i + 1]);
		    --i;
		}

		if (Sections.LastEntry [section] == INVALID_ENTRY) // No entry in this section.
		{
		    Sections.FirstEntry [section] = Sections.LastEntry [section] = Entries.Count;
		    Entries.PreviousEntry [Entries.Count] = INVALID_ENTRY;
		}
		else
		{
			Entries.NextEntry [Sections.LastEntry [section]] = Entries.Count;
			Entries.PreviousEntry [Entries.Count] = Sections.LastEntry [section];
			Sections.LastEntry [section] = Entries.Count;
		}
		++Entries.Count;
		FileChanged = true;
	}
	return 1;
}

stock DOF3::GetString (const file [], const key [], const tag [] = "")
{
	new buf [MAX_LINE_SIZE];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return buf;
}

stock DOF3::GetStringEx (const file [], const key [], result [], size, const tag [] = "")
{
	if (file [0] && key [0])
	{
	    new
	        pos,
			keybuf [MAX_LINE_SIZE];

        if (!CurrentFile [0] || strcmp (CurrentFile, file))
        {
	    	if (!DOF3::ParseFile (file, -1, false))
	    	{
	    	    result [0] = '\0';
	    	    return 0;
			}
		}

		// Find entry and assign the result with it's value.
		return (DOF3::SearchEntry (key, tag, keybuf, result, pos, sizeof (keybuf), size) != INVALID_ENTRY);
	}
	return 0;
}

stock DOF3::Unset (const file [], const key [], const tag [] = "")
{
	if (file [0] && key [0])
	{
	    new
	        entry,
	        pos,
			keybuf [MAX_LINE_SIZE],
			valbuf [MAX_LINE_SIZE];

		if (!CurrentFile [0] || strcmp (CurrentFile, file))
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

		if ((entry = DOF3::SearchEntry (key, tag, keybuf, valbuf, pos)) != INVALID_ENTRY)
		{
		    // Remove entry from it's section.
        #if MAX_SECTIONS >= 256
		    if (Sections.FirstEntry [Entries.Section [entry]] == entry) // Is the entry the first entry in the section? Make it's next entry the first entry.
		#else
		    if (Sections.FirstEntry [Entries.Section {entry}] == entry)
		#endif
			{
			#if MAX_SECTIONS >= 256
		        Sections.FirstEntry [Entries.Section [entry]] = Entries.NextEntry [entry];
			#else
			    Sections.FirstEntry [Entries.Section {entry}] = Entries.NextEntry [entry];
			#endif
		        if (Entries.NextEntry [entry] != INVALID_ENTRY)
					Entries.PreviousEntry [Entries.NextEntry [entry]] = INVALID_ENTRY;
			}
			else
			{
			    Entries.NextEntry [Entries.PreviousEntry [entry]] = Entries.NextEntry [entry];
			    if (Entries.NextEntry [entry] != INVALID_ENTRY)
					Entries.PreviousEntry [Entries.NextEntry [entry]] = Entries.PreviousEntry [entry];
			}

        #if MAX_SECTIONS >= 256
            if (Sections.LastEntry [Entries.Section [entry]] == entry)
        #else
			if (Sections.LastEntry [Entries.Section {entry}] == entry)
		#endif
			{
			#if MAX_SECTIONS >= 256
			    Sections.LastEntry [Entries.Section [entry]] = Entries.PreviousEntry [entry];
			#else
			    Sections.LastEntry [Entries.Section {entry}] = Entries.PreviousEntry [entry];
			#endif
			    if (Entries.PreviousEntry [entry] != INVALID_ENTRY)
			        Entries.NextEntry [Entries.PreviousEntry [entry]] = INVALID_ENTRY;
			}
			else
			{
			    Entries.PreviousEntry [Entries.NextEntry [entry]] = Entries.PreviousEntry [entry];
			    if (Entries.PreviousEntry [entry] != INVALID_ENTRY)
			        Entries.NextEntry [Entries.PreviousEntry [entry]] = Entries.NextEntry [entry];
			}

			// Move the entry to the end of the sorted list and decrement Entries.Count to forget about the unset Entries.
			while (pos < (Entries.Count - 1))
			{
			    DOF3::SwapSortedEntries (SortedEntryList [pos], SortedEntryList [pos + 1]);
			    ++pos;
			}
			--Entries.Count;
			FileChanged = true;
		    return 1;
		}
	}
	return 0;
}

stock DOF3::RenameKey (const file [], const oldkey [], const newkey [], const tag [] = "")
{
	if (file [0] && oldkey [0])
	{
	    new
	        entry,
	        pos,
		#if PACK_CONTENT == true
			line [MAX_LINE_SIZE],
		#endif
			keybuf [MAX_LINE_SIZE],
			valbuf [MAX_LINE_SIZE];

		if (!CurrentFile [0] || strcmp (CurrentFile, file))
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

		if ((entry = DOF3::SearchEntry (oldkey, tag, keybuf, valbuf, pos)) != INVALID_ENTRY)
		{
		    // Change content of Entries.
		#if PACK_CONTENT == true
            format (line, sizeof (line), "%s = %s", newkey, valbuf [0] ? valbuf : ("(null)"));
		    strpack (Entries.Line [entry], line);
		#else
            format (Entries.Line [entry], sizeof (Entries.Line []), "%s = %s", newkey, valbuf [0] ? valbuf : ("(null)"));
		#endif

		    // Because the hashcode has been changed, the entry has to move in the list.
		    SortedEntryList [pos][0] = DOF3::HashKey (newkey);
		    if (pos < (MAX_ENTRIES - 1) && SortedEntryList [pos][0] > SortedEntryList [pos + 1][0])
		    {
				// Hash value of key is greater than the hash value of it's right neighbor, move to the right by swapping the 2 entries.
				while (pos < (MAX_ENTRIES - 1) && SortedEntryList [pos][0] > SortedEntryList [pos + 1][0])
				{
				    DOF3::SwapSortedEntries (SortedEntryList [pos], SortedEntryList [pos + 1]);
				    ++pos;
				}
		    }
		    else if (pos > 0 && SortedEntryList [pos][0] < SortedEntryList [pos + 1][0])
		    {
		        // Hash value of key is smaller than the hash value of it' left neighbor, move to the left by swapping the 2 entries.
		        while (pos > 0 && SortedEntryList [pos][0] < SortedEntryList [pos - 1][0])
		        {
		            DOF3::SwapSortedEntries (SortedEntryList [pos], SortedEntryList [pos - 1]);
		            --pos;
		        }
		    }

			FileChanged = true;
		    return 1;
		}
	}
	return 0;
}

stock bool: DOF3::IsSet (const file [], const key [], const tag [] = "")
{
	new
	    pos,
		keybuf [MAX_LINE_SIZE],
		valbuf [MAX_LINE_SIZE];

	if (!CurrentFile [0] || strcmp (CurrentFile, file))
		if (!DOF3::ParseFile (file, -1, false))
		    return false;

	// Try to find the Entries.
	return (DOF3::SearchEntry (key, tag, keybuf, valbuf, pos) != INVALID_ENTRY);
}

stock DOF3::SetInt (const file [], const key [], value, const tag [] = "")
{
	new buf [16];
	format (buf, sizeof (buf), "%d", value);
	return DOF3::SetString (file, key, buf, tag);
}

stock DOF3::GetInt (const file [], const key [], const tag [] = "")
{
	new buf [16];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return strval (buf);
}

stock DOF3::SetHex (const file [], const key [], value, const tag [] = "")
{
	new buf [16];
	DOF3::hexstr (value, buf);
	return DOF3::SetString (file, key, buf, tag);
}

stock DOF3::GetHex (const file [], const key [], const tag [] = "")
{
	new buf [16];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return DOF3::strhex (buf);
}

stock DOF3::SetBin (const file [], const key [], value, const tag [] = "")
{
	new buf [35];
	DOF3::binstr (value, buf);
	return DOF3::SetString (file, key, buf, tag);
}

stock DOF3::GetBin (const file [], const key [], const tag [] = "")
{
	new buf [35];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return DOF3::strbin (buf);
}
Stock2:FamiliaExistes(const file[])
{
	if(DOF3_FileExists(file))
	{
		return 1;
	}
	return 0;
}
stock DOF3::SetFloat (const file [], const key [], Float: value, const tag [] = "")
{
	new buf [32];
	format (buf, sizeof (buf), "%.8f", value);
	return DOF3::SetString (file, key, buf, tag);
}

stock Float: DOF3::GetFloat (const file [], const key [], const tag [] = "")
{
	new buf [32];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return floatstr (buf);
}

stock bool: DOF3::GetBool (const file [], const key [], const tag [] = "")
{
	new buf [16];
	DOF3::GetStringEx (file, key, buf, sizeof (buf), tag);
	return (strval (buf) || (buf [0] && !strcmp (buf, "true", true)));
}

stock DOF3::SetBool (const file [], const key [], bool: value, const tag [] = "")
	return DOF3::SetString (file, key, value ? ("true") : ("false"), tag);
	
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

stock DOF3::PrintFile (const comment [] = "")
{
    if (CurrentFile [0])
	{
		new
			bool: firstline = true,
			entry,
		#if PACK_CONTENT == true
			buf [MAX_LINE_SIZE],
		#endif
			entries,
			i;

	    printf ("[DOF] Current file: %s", CurrentFile);
		for ( ; i < Sections.Count; ++i)
		{
		    if (i)
			{
			    if (!firstline)
					print (" ");
				else
				    firstline = false;
			#if PACK_CONTENT == true
				strunpack (buf, Sections.Tag [i]);
				printf ("[%s]", buf);
			#else
			    printf ("[%s]", Sections.Tag [i]);
			#endif
			}
			entry = Sections.FirstEntry [i];
			while (entry != INVALID_ENTRY)
			{
			#if PACK_CONTENT == true
				strunpack (buf, Entries.Line [entry]);
				print (buf);
			#else
			    print (Entries.Line [entry]);
			#endif
			    entry = Entries.NextEntry [entry];
			    firstline = false;
			    ++entries;
			}
		}
		printf ("* %d sections, %d entries", i, entries);
		if (comment [0])
			printf ("* Comment: %s", comment);
		return 1;
	}
	return 0;
}

stock DOF3::WriteFile ()
{
	if (CurrentFile [0])
	{
		new
			File: f = fopen (CurrentFile, io_write),
			bool: firstline = true,
			entry;

		if (f)
		{
			for (new i; i < Sections.Count; ++i)
			{
			    if (Sections.FirstEntry [i] != INVALID_ENTRY) // Do not write when empty.
			    {
				    if (i)
					{
					    if (!firstline)
						{
							fputchar (f, '\r', UseUTF8);
							fputchar (f, '\n', UseUTF8);
						}
						else
						    firstline = false;
						fputchar (f, '[', UseUTF8);
						fwritechars (f, Sections.Tag [i]);
						fputchar (f, ']', UseUTF8);
						fputchar (f, '\r', UseUTF8);
						fputchar (f, '\n', UseUTF8);
					}

					entry = Sections.FirstEntry [i];
					while (entry != INVALID_ENTRY)
					{
					    fwritechars (f, Entries.Line [entry]);
					    fputchar (f, '\r', UseUTF8);
					    fputchar (f, '\n', UseUTF8);
					    entry = Entries.NextEntry [entry];
					    firstline = false;
					}
				}
			}
			FileChanged = false;
			return fclose (f);
		}
	}
	return 0;
}

stock DOF3::ParseFile (const file [], extraid = -1, bool: callback = false)
{
    if (file [0] && DOF3::FileExists (file))
	{
	    /*
	    Write the file in the buffer when:
	    - There is actually a file in the buffer
	    - The file in the buffer is not the file you want to parse and this file has been changed.
	    - Or the current file is the file you want to and has been changed.
	    */
	    //if (CurrentFile [0] && ((strcmp (CurrentFile, file) && FileChanged) || FileChanged))
	    if (CurrentFile [0] && FileChanged) // Equal to the query above but shorter.
	    	DOF3::WriteFile ();

		new
			File: f = fopen (file, io_readwrite),
		    buf [MAX_LINE_SIZE],
		#if PACK_CONTENT == true
		    line [MAX_LINE_SIZE char],
		    tag [MAX_SECTION_TAG],
		#else
		    line [MAX_LINE_SIZE],
		#endif
		    key [MAX_LINE_SIZE],
		    value [MAX_LINE_SIZE],
			c,
			pos;

		if (f)
		{
			FileChanged = false;
            DOF3::SetFile (file);

			Sections.Count = 1;
			Entries.Count = 0;
			Sections.FirstEntry [0] = Sections.LastEntry [0] = INVALID_ENTRY;

			for (new i, size = flength (f); i < size; ++i)
			{
			    c = fgetchar (f, 0, UseUTF8);
				if (pos == MAX_LINE_SIZE - 1 || c == '\n' || c == '\r')
				    c = '\0';
			#if PACK_CONTENT == true
				line {pos++} = c;
			#else
			    line [pos++] = c;
			#endif

				if (c == '\0')
				{
				    // A new section found. Add the section to the list of sections.
				#if PACK_CONTENT == true
				    if (line {0} == '[')
				#else
                	if (line [0] == '[')
				#endif
				    {
				        if (Sections.Count < MAX_SECTIONS)
				        {
							pos = 1;
						#if PACK_CONTENT == true
							while (line {pos} && line {pos} != ']' && (pos - 1) < MAX_SECTION_TAG)
							{
								Sections.Tag [Sections.Count]{pos - 1} = line {pos};
								++pos;
							}
							Sections.Tag [Sections.Count]{pos - 1} = '\0';
						#else
						    while (line [pos] && line [pos] != ']' && (pos - 1) < MAX_SECTION_TAG)
							{
								Sections.Tag [Sections.Count][pos - 1] = line [pos];
								++pos;
							}
							Sections.Tag [Sections.Count][pos - 1] = '\0';
						#endif
							Sections.FirstEntry [Sections.Count] = Sections.LastEntry [Sections.Count] = INVALID_ENTRY;
							++Sections.Count;
					    }
				    }
				    else
				    {
					#if PACK_CONTENT == true
				        if (line {0})
					#else
					    if (line [0])
					#endif
				        {
				        #if PACK_CONTENT == true
							strunpack (buf, line);
					        DOF3::ParseLine (buf, key, value);
					        strunpack (tag, Sections.Tag [Sections.Count - 1]);

							// Call a specific function for a specific entry - ZCMD-style!
					        if (callback)
					        {
						        format (buf, sizeof (buf), "_OnParseFile_%s_%s", tag, key);
						        if (!CallRemoteFunction (buf, "is", extraid, value))
									CallRemoteFunction ("_OnDefaultParseFile", "issss", extraid, value [0] ? value : ("\1"), key, Sections.Tag [Sections.Count - 1][0] ? Sections.Tag [Sections.Count - 1] : ("\1"), file);
							}
						#else
					        DOF3::ParseLine (line, key, value);

							// Call a specific function for a specific entry - ZCMD-style!
					        if (callback)
					        {
						        format (buf, sizeof (buf), "_OnParseFile_%s_%s", Sections.Tag [Sections.Count - 1], key);
						        if (!CallRemoteFunction (buf, "is", extraid, value))
									CallRemoteFunction ("_OnDefaultParseFile", "issss", extraid, value [0] ? value : ("\1"), key, Sections.Tag [Sections.Count - 1][0] ? Sections.Tag [Sections.Count - 1] : ("\1"), file);
							}
						#endif

							// Add entry to it's section and to the list which will be sorted.
							Entries.Line [Entries.Count] = line;
							Entries.Tag [Entries.Count] = Sections.Tag [Sections.Count - 1];
                        #if MAX_SECTIONS >= 256
							Entries.Section [Entries.Count] = Sections.Count - 1;
						#else
							Entries.Section {Entries.Count} = Sections.Count - 1;
						#endif
							Entries.NextEntry [Entries.Count] = INVALID_ENTRY;

							SortedEntryList [Entries.Count][0] = DOF3::HashKey (key);
							SortedEntryList [Entries.Count][1] = Entries.Count;

							if (Sections.LastEntry [Sections.Count - 1] == INVALID_ENTRY)
							{
							    Sections.FirstEntry [Sections.Count - 1] = Sections.LastEntry [Sections.Count - 1] = Entries.Count;
							    Entries.PreviousEntry [Entries.Count] = INVALID_ENTRY;
							}
							else
							{
								Entries.NextEntry [Sections.LastEntry [Sections.Count - 1]] = Entries.Count;
								Entries.PreviousEntry [Entries.Count] = Sections.LastEntry [Sections.Count - 1];
								Sections.LastEntry [Sections.Count - 1] = Entries.Count;
							}
							++Entries.Count;
						}
				    }
				    pos = 0;
				}
			}
			/*
			 * Sort list of entries by it's hashcodes in O(n * log n) time.
			 * (Worst case is actually O(n * n), however, this QuickSort implementation chooses a randomized pivot
			 * to minimize the chance for the worst case.)
			 */
			DOF3::SortEntries (SortedEntryList, 0, Entries.Count - 1, true);
			return fclose (f);
		}
	}
	return 0;
}

// Rather useless.
stock DOF3::ReparseFile (const file [], extraid, bool: callback = true)
{
	if (file [0] && CurrentFile [0] && !strcmp (file, CurrentFile))
	{
	    CurrentFile [0] = '\0';
		return DOF3::ParseFile (file, extraid, callback);
	}
	return 0;
}

private DOF3::ParseLine (const line [], key [], value [], keysize = sizeof (key), valuesize = sizeof (value))
{
	new
		pos,
		readpos;

	if ((pos = charfind (line, '=')) != -1)
	{
	    // Read key and value.
	    readpos = pos - 1;
		while (readpos >= 0 && line [readpos] == ' ')
		    --readpos;

		if (readpos >= 0 && keysize > (readpos + 1))
		{
			key [readpos + 1] = '\0';
			while (readpos >= 0)
			{
				key [readpos] = line [readpos];
				--readpos;
			}
		}
		else
		    return 0;

		readpos = pos + 1;
		++pos;
		while (line [readpos] == ' ')
		{
			++pos;
		    ++readpos;
		}

        if (line [readpos])
		{
		    while (readpos >= 0 && line [readpos] && valuesize > (readpos - pos + 1))
			{
				value [readpos - pos] = line [readpos];
				++readpos;
			}
			value [readpos - pos] = '\0';
		}
		else
		{
		    key [0] = value [0] = '\0';
		    return 0;
		}
		
		if (!strcmp (value, "(null)", true))
		    value [0] = '\0';
		return 1;
	}
	key [0] = value [0] = '\0';
	return 0;
}

stock DOF3::File (const user [])
{
	new newfile [MAX_FILE_SIZE];
	format (newfile, sizeof (newfile), USER_FILE_PATH, DOF3::udb_encode (user));
	return newfile;
}

stock bool: DOF3::CheckLogin (const file [], const password [])
	return (file [0] && password [0] && DOF3::num_hash (password) == DOF3::GetInt (file, USER_PW_HASH_KEY));

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

stock DOF3::binstr (value, const dest [], size = sizeof (dest))
{
	new buf [32 + 3] = "0b";
	for (new i = 0; i < 32; ++i)
	    buf [i + 2] = '0' + ((value >>> (31 - i)) & 1);

	DOF3::strcpy (dest, buf, size);
}
	//format (dest, size, "0b%b", value);

stock DOF3::hexstr (value, const dest [], size = sizeof (dest))
{
	static const characters [] =
	{
	    '0', '1', '2', '3',
	    '4', '5', '6', '7',
	    '8', '9', 'A', 'B',
	    'C', 'D', 'E', 'F'
	};
	
	new buf [8 + 3] = "0x";
	
	for (new i = 0; i < 8; ++i)
		buf [2 + i] = characters [(value >>> ((7 - i) << 2)) & 0x0F];

	DOF3::strcpy (dest, buf, size);
}
	//format (dest, size, "0x%x", value);

stock DOF3::strhex (const string [])
{
	new
		i,
		value;
		
	if (string [0] == '0' && (string [1] == 'x' || string [1] == 'X'))
		i = 2;

    while (string [i])
    {
		value <<= 4;
		switch (string [i])
		{
		    case '0' .. '9':
		        value |= string [i] - '0';

			case 'A' .. 'F':
			    value |= string [i] - 'A' + 10;

            case 'a' .. 'f':
			    value |= string [i] - 'a' + 10;

			default:
			    return 0;
		}
		++i;
    }
    return value;
}

stock DOF3::strbin (const string [])
{
	new
	    i,
	    value;

	if (string [0] == '0' && (string [1] == 'b' || string [1] == 'B'))
	    i = 2;

	while (string [i])
	{
	    if (string [i] != '1' && string [i] != '0')
	        return 0;

		value <<= 1;
		value |= (string [i] - '0');
		++i;
	}
	return value;
}

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

private charfind (const string [], c)
{
	for (new i, len = strlen (string); i < len; ++i)
		if (string [i] == c)
		    return i;
	return -1;
}

private fwritechars (File: handle, const c [])
{
    new pos;
#if PACK_CONTENT == true
	while (c {pos})
	    fputchar (handle, c {pos++}, UseUTF8);
#else
    while (c [pos])
	    fputchar (handle, c [pos++], UseUTF8);
#endif
}

private DOF3::SortEntries (const entries [][2], l, r, bool: randomize = true)
{
	if (r > l)
	{
		if (randomize)
		{
			new k = l + (random (65535) % (r - l + 1));
		  	DOF3::SwapSortedEntries (entries [k], entries [r]);
		}

		new
			i = l - 1,
			j = r,
			pivot = entries [r][0];

		while (i < j)
		{
			do
				++i;
			while (entries [i][0] <= pivot && i < r);

			do
			    --j;
			while (entries [j][0] >= pivot && j > l);

			if (i < j)
			    DOF3::SwapSortedEntries (entries [i], entries [j]);
		}
		DOF3::SwapSortedEntries (entries [i], entries [r]);
		DOF3::SortEntries (entries, l, i - 1, randomize);
		DOF3::SortEntries (entries, i + 1, r, randomize);
	}
}

private DOF3::SwapSortedEntries (a [2], b [2])
{
 	new c [2];
	c [0] = a [0];
	c [1] = a [1];
	a [0] = b [0];
	a [1] = b [1];
	b [0] = c [0];
	b [1] = c [1];
}

stock DOF3::SortAllSections (const file [], bool: ignorecase = true, bool: ascending = true)
{
    if (file [0])
	{
	    if (!CurrentFile [0] || strcmp (CurrentFile, file)) // No file in buffer or the file you want to read from is not the file in the buffer.
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

		new
			entries [MAX_ENTRIES],
			keys [MAX_ENTRIES][MAX_LINE_SIZE],
			key [MAX_LINE_SIZE],
			value [MAX_LINE_SIZE],
	    #if PACK_CONTENT == true
			line [MAX_LINE_SIZE],
		#endif
			entry,
			i;

		for (new section = 0; section < Sections.Count; ++section)
		{
		    i = 0;
			entry = Sections.FirstEntry [section];
			while (entry != INVALID_ENTRY)
			{
	        #if PACK_CONTENT == true
		    	strunpack (line, Entries.Line [entry]);
			    DOF3::ParseLine (line, key, value);
			#else
			    DOF3::ParseLine (Entries.Line [entry], key, value);
			#endif
			    keys [i][0] = '\0';
			    strcat (keys [i], key);
			    entries [i] = entry;
			    entry = Entries.NextEntry [entry];
			    ++i;
			}

			if (i > 0)
				DOF3::SortSection_Internal (section, entries, keys, 0, i - 1, ignorecase, ascending);
		}
		return 1;
	}
	return 0;
}

stock DOF3::SortSection (const file [], const tag [], bool: ignorecase = true, bool: ascending = true)
{
	if (file [0])
	{
	    if (!CurrentFile [0] || strcmp (CurrentFile, file)) // No file in buffer or the file you want to read from is not the file in the buffer.
	    	if (!DOF3::ParseFile (file, -1, false))
	    	    return 0;

		new
		    section = INVALID_SECTION,
			entries [MAX_ENTRIES],
			keys [MAX_ENTRIES][MAX_LINE_SIZE],
			key [MAX_LINE_SIZE],
			buf [MAX_LINE_SIZE],
	    #if PACK_CONTENT == true
			line [MAX_LINE_SIZE],
		#endif
			entry,
			i;

		if (!tag [0])
			section = 0;
		else
		{
			for (i = 1; i < Sections.Count; ++i)
			{
			#if PACK_CONTENT == true
			    strunpack (buf, Sections.Tag [i]);
			    if (buf [0] && !strcmp (tag, buf, !CaseSensitive))
			    {
			        section = i;
			        break;
			    }
			#else
			    if (Sections.Tag [i][0] && !strcmp (tag, Sections.Tag [i], !CaseSensitive))
			    {
			        section = i;
			        break;
			    }
			#endif
			}
		}

		if (section != INVALID_SECTION)
		{
		    i = 0;
			entry = Sections.FirstEntry [section];
			while (entry != INVALID_ENTRY)
			{
	        #if PACK_CONTENT == true
		    	strunpack (line, Entries.Line [entry]);
			    DOF3::ParseLine (line, key, buf);
			#else
			    DOF3::ParseLine (Entries.Line [entry], key, buf);
			#endif
			    keys [i][0] = '\0';
			    strcat (keys [i], key);
			    entries [i] = entry;
			    entry = Entries.NextEntry [entry];
			    ++i;
			}

			if (i > 0)
			{
				DOF3::SortSection_Internal (section, entries, keys, 0, i - 1, ignorecase, ascending);
		    	return 1;
			}
		}
	}
	return 0;
}

private DOF3::SortSection_Internal (section, entries [], keys [][], l, r, bool: ignorecase = true, bool: ascending = true)
{
	// Entries must be stored into an array...
    if (0 <= section < Sections.Count && r > l)
    {
        new
            i = l - 1,
            j = r,
			buf [MAX_LINE_SIZE];

        static
            pivot [MAX_LINE_SIZE]; // Must be static, otherwise too much memory usage during recursion ==> Script will crash!

        pivot [0] = '\0';
        strcat (pivot, keys [r]);

        while (i < j)
        {
            if (ascending)
            {
                do
                    ++i;
                while (strcmp (keys [i], pivot,  ignorecase) <= 0 && i < r);

                do
                    --j;
                while (strcmp (keys [j], pivot, ignorecase) >= 0 && j > l);
            }
            else
            {
                do
                    ++i;
                while (strcmp (keys [i], pivot,  ignorecase) >= 0 && i < r);

                do
                    --j;
                while (strcmp (keys [j], pivot, ignorecase) <= 0 && j > l);
            }

            if (i < j)
            {
                DOF3::SwapEntries (section, entries [i], entries [j]);

				DOF3::strcpy (buf, keys [i]);
				DOF3::strcpy (keys [i], keys [j], MAX_LINE_SIZE);
				DOF3::strcpy (keys [j], buf, MAX_LINE_SIZE);

				entries [i] ^= entries [j];
                entries [j] ^= entries [i];
                entries [i] ^= entries [j];
			}
        }

        if (i != r)
        {
            DOF3::SwapEntries (section, entries [i], entries [r]);

            DOF3::strcpy (buf, keys [i]);
			DOF3::strcpy (keys [i], keys [r], MAX_LINE_SIZE);
			DOF3::strcpy (keys [r], buf, MAX_LINE_SIZE);

            entries [i] ^= entries [r];
            entries [r] ^= entries [i];
            entries [i] ^= entries [r];
		}

        DOF3::SortSection_Internal (section, entries, keys, l, i - 1, ignorecase, ascending);
        DOF3::SortSection_Internal (section, entries, keys, i + 1, r, ignorecase, ascending);
    }
}

private DOF3::SwapEntries (section, entry1, entry2)
{
	// This swaps two entries in the entry list of a section. (Pointers are swapped)
	if (0 <= section < Sections.Count && 0 <= entry1 <= Entries.Count && 0 <= entry2 <= Entries.Count)
	{
	    if (entry1 == Sections.FirstEntry [section])
		    Sections.FirstEntry [section] = entry2;
		else if (entry2 == Sections.FirstEntry [section])
		    Sections.FirstEntry [section] = entry1;

	    if (entry1 == Sections.LastEntry [section])
		    Sections.LastEntry [section] = entry2;
		else if (entry2 == Sections.LastEntry [section])
		    Sections.LastEntry [section] = entry1;

		if (Entries.NextEntry [entry1] == entry2)
		{
		    Entries.NextEntry [entry1] = Entries.NextEntry [entry2];
		    Entries.PreviousEntry [entry2] = Entries.PreviousEntry [entry1];

		    if (Entries.PreviousEntry [entry1] != INVALID_ENTRY)
		        Entries.NextEntry [Entries.PreviousEntry [entry1]] = entry2;

	        if (Entries.NextEntry [entry2] != INVALID_ENTRY)
		        Entries.PreviousEntry [Entries.NextEntry [entry2]] = entry1;

		    Entries.NextEntry [entry2] = entry1;
		    Entries.PreviousEntry [entry1] = entry2;
		}
		else if (Entries.NextEntry [entry2] == entry1)
		{
		    Entries.NextEntry [entry2] = Entries.NextEntry [entry1];
		    Entries.PreviousEntry [entry1] = Entries.PreviousEntry [entry2];

		    if (Entries.PreviousEntry [entry2] != INVALID_ENTRY)
		        Entries.NextEntry [Entries.PreviousEntry [entry2]] = entry1;

	        if (Entries.NextEntry [entry1] != INVALID_ENTRY)
		        Entries.PreviousEntry [Entries.NextEntry [entry1]] = entry2;

		    Entries.NextEntry [entry1] = entry2;
		    Entries.PreviousEntry [entry2] = entry1;
		}
		else
		{
		    new pointer;

			if (Entries.PreviousEntry [entry1] != INVALID_ENTRY)
			    Entries.NextEntry [Entries.PreviousEntry [entry1]] = entry2;

		    if (Entries.NextEntry [entry1] != INVALID_ENTRY)
			    Entries.PreviousEntry [Entries.NextEntry [entry1]] = entry2;

			if (Entries.PreviousEntry [entry2] != INVALID_ENTRY)
			    Entries.NextEntry [Entries.PreviousEntry [entry2]] = entry1;

		    if (Entries.NextEntry [entry2] != INVALID_ENTRY)
			    Entries.PreviousEntry [Entries.NextEntry [entry2]] = entry1;

			pointer = Entries.NextEntry [entry1];
			Entries.NextEntry [entry1] = Entries.NextEntry [entry2];
			Entries.NextEntry [entry2] = pointer;

			pointer = Entries.PreviousEntry [entry1];
			Entries.PreviousEntry [entry1] = Entries.PreviousEntry [entry2];
			Entries.PreviousEntry [entry2] = pointer;
		}
	    return 1;
	}
	return 0;
}

private DOF3::HashKey (const key [])
{
	new
		h = -1,
		i,
		j;

	if (CaseSensitive)
	{
		while ((j = key [i++]))
			h = h * 33 + j;
	}
	else
	{
	    while ((j = tolower (key [i++])))
	        h = h * 33 + j;
	}
	return h;
}

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

stock DOF3::strcpy (dest [], const src [], size = sizeof (dest))
{
	dest [0] = '\0';
	strcat (dest, src, size);
}

// Replace [oldstr] with [newstr] in [srcstr] and copy write the new string to 'deststr'.

stock DOF3::strreplace (const newstr [], const oldstr [], const srcstr [], deststr [], bool: ignorecase = false, size = sizeof (deststr))
{
	new
	    newlen = strlen (newstr),
	    oldlen = strlen (oldstr),
	    srclen = strlen (srcstr),
	    idx,
		rep;

	for (new i = 0; i < srclen; ++i)
	{
	    if (idx < (size - 1))
	    {
		    if ((i + oldlen) <= srclen)
		    {
		        if (!strcmp (srcstr [i], oldstr, ignorecase, oldlen))
		        {
					deststr [idx] = '\0';
					strcat (deststr, newstr, size);
					++rep;
					idx += newlen;
					i += oldlen - 1;
				}
				else
					deststr [idx++] = srcstr [i];
		    }
		    else
		    	deststr [idx++] = srcstr [i];
	    }
		else
		    return rep;
	}
	deststr [idx] = '\0';
	return rep;
}

stock DOF3::udb_encode (const nickname [])
{
	new
		buf [256],
		result [256];

	static const symbols [][2][] =
	{
	    {"_", "_00"},
		{";", "_01"},
		{"!", "_02"},
		{"/", "_03"},
		{"\\", "_04"},
		{"[", "_05"},
		{"]", "_06"},
		{"?", "_07"},
		{".", "_08"},
		{"*", "_09"},
		{"<", "_10"},
		{">", "_11"},
		{"{", "_12"},
		{"}", "_13"},
		{" ", "_14"},
		{"\"", "_15"},
		{":", "_16"},
		{"|", "_17"},
		{"=", "_18"}
	};

	strcat (buf, nickname);
	for (new i = 0; i < sizeof (symbols); ++i)
	{
	    DOF3::strreplace (symbols [i][1], symbols [i][0], buf, result);
	    DOF3::strcpy (buf, result);
	}
	return result;
}

stock DOF3::udb_decode (const nickname [])
{
	new
		buf [256],
		result [256];

	static const symbols [][2][] =
	{
	    {"_", "_00"},
		{";", "_01"},
		{"!", "_02"},
		{"/", "_03"},
		{"\\", "_04"},
		{"[", "_05"},
		{"]", "_06"},
		{"?", "_07"},
		{".", "_08"},
		{"*", "_09"},
		{"<", "_10"},
		{">", "_11"},
		{"{", "_12"},
		{"}", "_13"},
		{" ", "_14"},
		{"\"", "_15"},
		{":", "_16"},
		{"|", "_17"},
		{"=", "_18"}
	};

	strcat (buf, nickname);
	for (new i = 0; i < sizeof (symbols); ++i)
	{
	    DOF3::strreplace (symbols [i][0], symbols [i][1], buf, result);
	    DOF3::strcpy (buf, result);
	}
	return result;
}

stock DOF3::num_hash (const buf [])
{
	new
		length = strlen (buf),
    	s1 = 1,
    	s2 = 0,
    	n;

    for (n = 0; n < length; n++)
	{
       s1 = (s1 + buf [n]) % 65521;
       s2 = (s2 + s1) % 65521;
    }
    return (s2 << 16) + s1;
}

/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/

#if defined DUDB_CONVERT

	#tryinclude <dutils>

	#define dUser(%0).( 			DOF3_GetString(DOF3_File(%0),
	#define dUserSet(%0).( 			DOF3_SetString(DOF3_File(%0),
	#define dUserINT(%0).( 			DOF3_GetInt(DOF3_File(%0),
	#define dUserSetINT(%0).( 		DOF3_SetInt(DOF3_File(%0),
	#define dUserFLOAT(%0).( 		DOF3_GetFloat(DOF3_File(%0),
	#define dUserSetFLOAT(%0).( 	DOF3_SetFloat(DOF3_File(%0),
	#define udb_Create(%0,%1)		DOF3_CreateFile(DOF3_File(%0),%1)
	#define udb_RenameUser(%0,%1)   DOF3_RenameFile(DOF3_File(%0),DOF3_File(%1))
	#define udb_Exists(%0)          DOF3_FileExists(DOF3_File(%0))
	#define udb_Remove(%0)          DOF3_RemoveFile(DOF3_File(%0))
	#define udb_CheckLogin(%0,%1)   DOF3_CheckLogin(DOF3_File(%0),%1)

	#if !defined _dudb_included
		#define _dudb_included
	#endif

#endif

#if defined DINI_CONVERT

	#define dini_Exists		        DOF3_FileExists
	#define dini_Remove         	DOF3_RemoveFile
	#define dini_Create         	DOF3_CreateFile
	#define dini_Set			    DOF3_SetString
	#define dini_Get         		DOF3_GetString
	#define dini_IntSet   			DOF3_SetInt
	#define dini_Int         		DOF3_GetInt
	#define dini_BoolSet            DOF3_SetBool
	#define dini_Bool               DOF3_GetBool
	#define dini_FloatSet 			DOF3_SetFloat
	#define dini_Float      		DOF3_GetFloat
	#define dini_Unset       		DOF3_Unset
	#define dini_Isset       		DOF3_IsSet

	#if !defined _dini_included
		#define _dini_included
	#endif

#endif

/*
#if defined DINI_CONVERT || defined DUDB_CONVERT

	#define udb_hash            	DOF3_num_hash
	#define num_hash            	DOF3_num_hash
	#define udb_encode              DOF3_udb_encode
	#define udb_decode              DOF3_udb_decode

#endif
*/