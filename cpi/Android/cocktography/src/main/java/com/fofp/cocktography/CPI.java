package com.fofp.cocktography;

import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Random;


public class CPI {


    Resources res;
    private String[] wide_chodes;
    private String[] cock_bytes;
    private Hashtable<String,String> kontol_chodes = new Hashtable<>();
    private Hashtable<String,Integer> reverse_wide = new Hashtable<>();
    private Hashtable<String,Integer> reverse_cock = new Hashtable<>();
    private byte sentinel = 0x0f;
    private Random rand = new Random();
    public enum CockMode {
        THIN_CHODE,
        WIDE_CHODE,
        MIXED_CHODE
    }

    //Calling the constructor pre-loads the dicktionaries into cache.
    public CPI(Context context) {
        //Calling app needs to send the context to get the resources.
        // I don't like that, but haven't figured out how to make it not dumb.
        res = context.getResources();
        wide_chodes = res.getStringArray(R.array.rodsetta_stone);
        cock_bytes = res.getStringArray(R.array.cock_bytes);

        //push kontol chodes into bidirectional hash for easy retrieval.
        String[] tmp = res.getStringArray(R.array.kontol_chodes);
        for (int i = 0; i < tmp.length; ++i) {

            kontol_chodes.put(tmp[i].split(" ")[0],tmp[i].split(" ")[1] );
            kontol_chodes.put(tmp[i].split(" ")[1],tmp[i].split(" ")[0] );
        }
        //The others, I guess, will go into one way hashes for retrieval.
        for (int i = 0; i < wide_chodes.length; ++i) {
            reverse_wide.put(wide_chodes[i], i);
        }
        for (int i = 0; i < cock_bytes.length; ++i){
            reverse_cock.put(cock_bytes[i], i);
        }
    }

    //This takes a string of data and returns it as enchoded cockblocks.
    // text - the data to become chodes
    // strokes - the higher this value, the more fluffs the data gets
    // maxLength - The maximum length each cockblock should be
    // mode - thin/wide/mixed (mixed is probably best for most applications, wide is best for saving space)
    // Returns an array. Each element in the array is one cockblock of the length specified.
    // transmit them in order ([0], [1], et al) May only have a single element.
    public String[] Enchode (String text, Integer strokes, Integer maxLength,CockMode mode) {
        StringBuilder chodes = new StringBuilder();
        List<String> cockblocks = new ArrayList<>();
        //strokes
        //cockblock size


        String cocks = BytesToChodes(Stroke(text,strokes).getBytes(), mode);
        chodes.append(kontol_chodes.get("START"));

        for (String cock : cocks.split(" ")) {
            if (chodes.length() + cock.length() + kontol_chodes.get("STOP").length() + 2 > maxLength) {
                chodes.append(String.format(" %s",kontol_chodes.get("CONT")));
                cockblocks.add(chodes.toString());
                chodes.setLength(0);
                chodes.append(String.format("%s %s",kontol_chodes.get("MARK"), cock));
            } else {
                chodes.append(String.format(" %s",cock));
            }
        }
        chodes.append(String.format(" %s",kontol_chodes.get("STOP")));
        cockblocks.add(chodes.toString());

        return cockblocks.toArray(new String[0]);
    }

    //Pass in a string of chodes, it'll return an array:
    //[0] is the stroke count
    //[1] is the dechoded messagea
    public String[] Dechode(String chodes) {
        return Destroke(new String(ChodesToBytes(chodes), Charset.forName("UTF-8")));
    }

    //Fluffs and obscures text by applying Base64 encodings until the stroke count is reached
    private String Stroke(String text, Integer count) {
        text = ((char) sentinel + text);

        while (count > 0) {
            text = Base64.encodeToString(text.getBytes(),Base64.NO_WRAP);
            --count;
        }
        return text;
    }

    private String BytesToChodes(byte[] data, CockMode mode) {
        return BytesToChodes(data,mode,70);
    }
    //Converts bytes to ascii schlongs for any kinda use
    private String BytesToChodes(byte[] data, CockMode mode, Integer variance) {
        List<String> dicks = new ArrayList<String>();

        byte prev = 0;
        boolean eatme = false;

        if (mode == CockMode.THIN_CHODE) {
            for (byte b :data) {
                dicks.add(cock_bytes[(int)b]);
            }
        }
        //if "123" data = byte[3] {49,50,31};
        //String came in single byte.
        if (mode == CockMode.WIDE_CHODE) {

            for (byte b : data) {
                if (!eatme) {
                    eatme = true;
                    prev = b;
                } else {
                    dicks.add(wide_chodes[(prev << 8 | b)]);
                    eatme = false;
                }
            }
            if (eatme) {
                dicks.add(cock_bytes[prev]);
            }
        }
        if (mode == CockMode.MIXED_CHODE) {
            for (byte b : data) {
                if (rand.nextInt(100) + 1 < variance) {
                    if (!eatme) {
                        dicks.add(cock_bytes[b]);
                        eatme = false;
                    } else {
                        dicks.add(cock_bytes[prev]);
                        prev = b;
                        eatme = true;
                    }
                } else {
                    if (!eatme) {
                        eatme = true;
                        prev = b;
                    } else {
                        dicks.add(wide_chodes[(prev << 8 | b)]);
                        eatme = false;
                    }
                }
            }
            if (eatme) {
                dicks.add(cock_bytes[prev]);
            }
        }
        return TextUtils.join(" ",dicks);
    }

    private byte[] ChodesToBytes(String chodes) {
        ByteArrayOutputStream result = new ByteArrayOutputStream();

        byte[] buff = new byte[2];
        Integer value;
        for ( String chode : chodes.split(" ")) {

            if ((value = reverse_wide.get(chode)) != null) {
                buff[0] = (byte)(value >> 8);
                buff[1] = (byte)(value & 0xFF);

                result.write(buff,0,2);
            }
            if ((value = reverse_cock.get(chode)) != null) {
                buff[0] = (byte)(value & 0xFF);

                result.write(buff,0,1);
            }
        }
        return result.toByteArray();
    }

    private String[] Destroke(String text) {
        Integer strokes = 0;
        while(text.charAt(0) != sentinel && text.length() % 4 == 0 && text.length() > 0) {
            text = new String(Base64.decode(text,0));
            ++strokes;
        }
        return new String[] { strokes.toString(),text.replaceFirst("^\\x0f","")};
    }

}