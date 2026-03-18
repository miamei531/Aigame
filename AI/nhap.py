import cv2
import pyautogui
from myPose import myPose

class Player:
    def __init__(self, name="Player"):
        self.name = name
        self.pose = myPose()
        self.game_started = False
        self.x_position = 1  # 0: trái, 1: giữa, 2: phải
        self.y_position = 1  # 0: xuống, 1: đứng, 2: nhảy
        self.clap_duration = 0
        self.clapable = True
        self.Hands_UP_duration = 0
        self.T_Pose_duration = 0
    def move_LRC(self, LRC):
        if LRC == "L":
            for _ in range(0, self.x_position, 1):
                pyautogui.press("left")
            self.x_position = 0
        elif LRC == "R":
            for _ in range(2, self.x_position, -1):
                pyautogui.press("right")
            self.x_position = 2
        else:
            self.x_position = 1

    def move_JSD(self, JSD):
        if JSD == "J" and self.y_position == 1:
            pyautogui.press("up")
            self.y_position = 2
        elif JSD == "D" and self.y_position == 1:
            pyautogui.press("down")
            self.y_position = 0
        elif JSD == "S" and self.y_position != 1:
            self.y_position = 1

    def move_T_Pose(self, T_pose):
        if T_pose == "T_Pose" :
            self.T_Pose_duration += 1
            if self.T_Pose_duration == 20 :
                 pyautogui.press("t")
        else :
            self.T_Pose_duration =0

    def move_LRC_2(self, LRC):
        if LRC == "L":
            for _ in range(0, self.x_position, 1):
                pyautogui.press("a")
            self.x_position = 0
        elif LRC == "R":
            for _ in range(2, self.x_position, -1):
                pyautogui.press("d")
            self.x_position = 2
        else:
            self.x_position = 1

    def move_JSD_2(self, JSD):
        if JSD == "J" and self.y_position == 1:
            pyautogui.press("w")
            self.y_position = 2
        elif JSD == "D" and self.y_position == 1:
            pyautogui.press("s")
            self.y_position = 0
        elif JSD == "S" and self.y_position != 1:
            self.y_position = 1

class myGame:
    def __init__(self):
        self.player1 = Player("Player 1")
        self.player2 = Player("Player 2")
        self.multiplay = False
    def play(self):
        cap = cv2.VideoCapture(0)
        cap.set(3, 1280)
        cap.set(4, 960)
        while True:
            Hands = None
            ret, image = cap.read()
            if not ret:
                break

            image = cv2.flip(image, 1)
            image_height, image_width, _ = image.shape

            if not self.multiplay:
                image, results = self.player1.pose.detectPose(image)
                if results.pose_landmarks:
                    if self.player1.game_started:
                        image, LRC = self.player1.pose.checkPose_LRC(image, results)
                        self.player1.move_LRC(LRC)

                        image, JSD = self.player1.pose.checkPose_JSD(image, results)
                        self.player1.move_JSD(JSD)

                        image, T_Pose = self.player1.pose.checkPose_T(image, results)
                        self.player1.move_T_Pose(T_Pose)
                    else:
                        cv2.putText(image, "Clap your hand to start!",
                                    (5, image_height - 10),
                                    cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 0), 3)

                    image, CLAP = self.player1.pose.checkPose_Clap(image, results)
                    if CLAP == "C" and self.player1.clapable:
                        self.player1.clap_duration += 1
                        if self.player1.clap_duration == 7:
                            self.player1.pose.save_shoulder_line_y(image, results)
                            pyautogui.press("space")
                            self.player1.game_started = True
                            self.player1.clap_duration = 0
                            self.player1.clapable = False
                    elif CLAP != "C":
                        self.player1.clap_duration = 0
                        self.player1.clapable = True

                    image, Hands = self.player1.pose.checkPose_Hands_up(image, results)
                    
                cv2.imshow("Game", image)

            else:
                half_width = image_width // 2
                left_img = image[:, :half_width].copy()
                right_img = image[:, half_width:].copy()

                # Player 1
                left_img, results1 = self.player1.pose.detectPose(left_img)
                if results1.pose_landmarks:
                    if self.player1.game_started:
                        left_img, LRC1 = self.player1.pose.checkPose_LRC(left_img, results1)
                        self.player1.move_LRC(LRC1)

                        left_img, JSD1 = self.player1.pose.checkPose_JSD(left_img, results1)
                        self.player1.move_JSD(JSD1)

                        left_img, T_Pose = self.player1.pose.checkPose_T(left_img, results1)
                        self.player1.move_T_Pose(T_Pose)
                    else:
                        cv2.putText(left_img, "Clap to start!",
                                    (10, image_height - 10),
                                    cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 0), 2)

                    left_img, CLAP1 = self.player1.pose.checkPose_Clap(left_img, results1)
                    if CLAP1 == "C" and self.player1.clapable:
                        self.player1.clap_duration += 1
                        if self.player1.clap_duration == 7:
                            self.player1.pose.save_shoulder_line_y(left_img, results1)
                            pyautogui.press("space")
                            self.player1.game_started = True
                            self.player1.clap_duration = 0
                            self.player1.clapable = False
                    elif CLAP1 != "C":
                        self.player1.clap_duration = 0
                        self.player1.clapable = True

                    left_img, Hands = self.player1.pose.checkPose_Hands_up(left_img, results1)

                # Player 2
                right_img, results2 = self.player2.pose.detectPose(right_img)
                if results2.pose_landmarks:
                    if self.player2.game_started:
                        right_img, LRC2 = self.player2.pose.checkPose_LRC(right_img, results2)
                        self.player2.move_LRC_2(LRC2)

                        right_img, JSD2 = self.player2.pose.checkPose_JSD(right_img, results2)
                        self.player2.move_JSD_2(JSD2)
                    else:
                        cv2.putText(right_img, "Clap to start!",
                                    (10, image_height - 10),
                                    cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 0), 2)

                    right_img, CLAP2 = self.player2.pose.checkPose_Clap(right_img, results2)
                    if CLAP2 == "C" and self.player2.clapable:
                        self.player2.clap_duration += 1
                        if self.player2.clap_duration == 7:
                            self.player2.pose.save_shoulder_line_y(right_img, results2)
                            pyautogui.press("space")
                            self.player2.game_started = True
                            self.player2.clap_duration = 0
                            self.player2.clapable = False
                    elif CLAP2 != "C":
                        self.player2.clap_duration = 0
                        self.player2.clapable = True

                cv2.imshow("Player 1", left_img)
                cv2.imshow("Player 2", right_img)           
            if  self.player1.game_started:
                if Hands == "Hands_UP" :
                    self.player1.Hands_UP_duration += 1
                    if self.player1.Hands_UP_duration == 30 :
                        if self.multiplay:
                            cv2.destroyWindow("Player 1")
                            cv2.destroyWindow("Player 2")
                            self.player1.game_started = False
                        else:
                            cv2.destroyWindow("Game")
                            self.player1.game_started = False
                            self.player2.game_started = False
                        self.multiplay = not self.multiplay
                else :
                    self.player1.Hands_UP_duration =0

            key = cv2.waitKey(1)
            if key == ord('q'):
                break


        cap.release()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    game = myGame()
    game.play()
