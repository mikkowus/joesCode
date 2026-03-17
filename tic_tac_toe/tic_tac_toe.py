def draw_board(board):
    # row 1 board list ["x","o","x"....]
    print(f" {board[0]} | {board[1]} | {board[2]} ")
    # row 1
    print("---|---|---")
    # row 2 board list ["o","x","o"....]
    print(f" {board[3]} | {board[4]} | {board[5]} ")
    # row 2
    print("---|---|---")
    # row 2 board list ["x","o","o"....]
    print(f" {board[6]} | {board[7]} | {board[8]} ")


def player_input():
    pass

def validate_plays():
    pass

def game_loop(quit_game):
    #while quit_game = false:
    pass


if __name__ == "__main__":
    #game_loop()
    board_state = [" "," "," ",
                   " "," "," ",
                   " "," "," "]
    draw_board(board_state)
