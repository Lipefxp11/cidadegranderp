package com.gta.launcher.activity;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import static org.junit.Assert.*;

public class BootConfigTest {
    @Test public void avatarIsInstalledAndRepairedWithoutChangingGameData() throws Exception {
        File root=temporary.newFolder();
        File core=new File(root,"core_data.bin");
        Files.write(core.toPath(),new byte[]{4,5,6});
        BootConfig.ensure(root,packagedConfig());
        File avatar=new File(root,"texdb/bcgskin/bcgskin.dxt.dat");
        assertEquals(699120L,avatar.length());
        Files.write(avatar.toPath(),new byte[]{0});
        assertThrows(IOException.class,()->BootConfig.verify(root));
        assertTrue(BootConfig.ensure(root,packagedConfig()));
        assertEquals(699120L,avatar.length());
        assertArrayEquals(new byte[]{4,5,6},Files.readAllBytes(core.toPath()));
    }
    @Rule public TemporaryFolder temporary = new TemporaryFolder();

    private BootConfig.AssetSource packagedConfig() {
        return name -> new FileInputStream(new File("src/main/assets", name));
    }

    @Test public void restoresConfigMissingFromInstalledV023Data() throws Exception {
        File root = temporary.newFolder();
        Files.write(new File(root, "keep_game_data.bin").toPath(), new byte[]{1, 2, 3});
        assertTrue(BootConfig.ensure(root, packagedConfig()));
        BootConfig.verify(root);
        assertArrayEquals(new byte[]{1, 2, 3}, Files.readAllBytes(new File(root, "keep_game_data.bin").toPath()));
    }

    @Test public void restartRetainsValidConfigWithoutReadingAssetAgain() throws Exception {
        File root = temporary.newFolder();
        BootConfig.ensure(root, packagedConfig());
        assertFalse(BootConfig.ensure(root, name -> { throw new IOException("Asset should not be read"); }));
        BootConfig.verify(root);
    }

    @Test public void repairsDamagedConfigBeforePlay() throws Exception {
        File root = temporary.newFolder();
        File stream = new File(root, BootConfig.FILE_NAME);
        Files.write(stream.toPath(), "memory 0".getBytes(StandardCharsets.UTF_8));
        assertTrue(BootConfig.ensure(root, packagedConfig()));
        BootConfig.verify(root);
    }

    @Test public void detectsAndRepairsDeletionBetweenLauncherAndPlay() throws Exception {
        File root = temporary.newFolder();
        BootConfig.ensure(root, packagedConfig());
        Files.delete(new File(root, BootConfig.FILE_NAME).toPath());
        assertThrows(IOException.class, () -> BootConfig.verify(root));
        assertTrue(BootConfig.ensure(root, packagedConfig()));
        BootConfig.verify(root);
    }

    @Test public void refusesWrongPackagedConfigAndLeavesExistingFileIntact() throws Exception {
        File root = temporary.newFolder();
        byte[] before = "original config".getBytes(StandardCharsets.UTF_8);
        File stream = new File(root, BootConfig.FILE_NAME);
        Files.write(stream.toPath(), before);
        assertThrows(IOException.class, () -> BootConfig.ensure(root, name -> new ByteArrayInputStream(new byte[197])));
        assertArrayEquals(before, Files.readAllBytes(stream.toPath()));
        assertEquals(1, root.list().length);
    }

    @Test public void upgradesInstalledV024WithoutChangingItsStreamOrGameData() throws Exception {
        File root = temporary.newFolder();
        byte[] stream = Files.readAllBytes(new File("src/main/assets", BootConfig.ASSET_PATH).toPath());
        Files.write(new File(root, BootConfig.FILE_NAME).toPath(), stream);
        File game = new File(root, "game_data.bin");
        Files.write(game.toPath(), new byte[]{7, 8, 9});
        assertTrue(BootConfig.ensure(root, name -> {
            if (name.equals(BootConfig.ASSET_PATH)) throw new IOException("Existing stream must be retained");
            return packagedConfig().open(name);
        }));
        BootConfig.verify(root);
        assertArrayEquals(stream, Files.readAllBytes(new File(root, BootConfig.FILE_NAME).toPath()));
        assertArrayEquals(new byte[]{7, 8, 9}, Files.readAllBytes(game.toPath()));
        assertEquals(16L, new File(root, BootConfig.SCRIPT_FILE_NAME).length());
    }

    @Test public void repairsTruncatedScriptMetadataBeforePlay() throws Exception {
        File root = temporary.newFolder();
        BootConfig.ensure(root, packagedConfig());
        File scv = new File(root, BootConfig.SCRIPT_FILE_NAME);
        Files.write(scv.toPath(), new byte[8]);
        assertThrows(IOException.class, () -> BootConfig.verify(root));
        assertTrue(BootConfig.ensure(root, packagedConfig()));
        BootConfig.verify(root);
        assertEquals(16L, scv.length());
    }

    @Test public void refusesWrongScriptMetadataAssetWithoutReplacingExistingFile() throws Exception {
        File root = temporary.newFolder();
        BootConfig.ensure(root, packagedConfig());
        File scv = new File(root, BootConfig.SCRIPT_FILE_NAME);
        byte[] damaged = new byte[16]; damaged[0] = 1;
        Files.write(scv.toPath(), damaged);
        assertThrows(IOException.class, () -> BootConfig.ensure(root, name -> {
            byte[] wrong = new byte[16]; wrong[1] = 1;
            return new ByteArrayInputStream(wrong);
        }));
        assertArrayEquals(damaged, Files.readAllBytes(scv.toPath()));
        assertEquals(1, scv.getParentFile().list().length);
    }
}
