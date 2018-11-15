package io.codigo.encryption;

import org.keyczar.KeyczarTool;

import java.nio.file.Path;
import java.nio.file.Paths;

public class KeyczarToolThing {

    public static void main(String[] args) {
        Path dir = Paths.get("/Users/andrew/code/backups/keyczar-staging");

        KeyczarParams addKey = new KeyczarParams(KeyczarCommand.ADDKEY)
                .withLocation(dir)
                .withSize(256);
        KeyczarTool.main(addKey.build());

        KeyczarParams promote = new KeyczarParams(KeyczarCommand.PROMOTE)
                .withLocation(dir)
                .withVersion(2);
        KeyczarTool.main(promote.build());
    }
}