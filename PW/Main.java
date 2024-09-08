import java.io.IOException;
import java.time.Clock;

public class Main {
    private static volatile int progress = 0;
    private static volatile boolean canDownload = false;
    private static final int PROGRESS_MAX = 100;

    private static void startDownloading() throws InterruptedException {
        while (canDownload && progress < PROGRESS_MAX) {
            canDownload = false;
            Thread.sleep(50);
            progress++;
        }
    }

    private static class Download implements Runnable {
        @Override
        public void run() {
            try {
               startDownloading();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("Download interrupted");
            }
        }

    }

    private static class Enter implements Runnable {
        @Override
        public void run() {
            while (true) {
                // This clears the console
                System.out.print("\033[H\033[2J");
                System.out.flush();

                if (progress == 0) {
                    System.out.println("Press enter to start downloading");
                } else if (progress == 100) {
                    System.out.println("Download complete");
                }
                System.out.println("Time: " + Clock.systemDefaultZone().instant().toString());
                System.out.println("Progress: " + progress + " / " + PROGRESS_MAX);
                try {

                    // Check if user pressed enter
                    if (System.in.available() > 0 && System.in.read() == '\n') {
                        canDownload = true;
                    } else {
                        Thread.sleep(100);
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    return;
                } catch (IOException e) {
                    return;
                }
            }
        }

    }

    public static void main(String[] args) {
        Thread e = new Thread(new Enter());
        Thread d = new Thread(new Download());
        e.start();
        d.start();
        try {
            e.join();
            d.join();
        }
        catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
            System.out.println("Main interrupted");
            e.interrupt();
            d.interrupt();
        }
    }
}
