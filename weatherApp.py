def ask_yes_no(question):
    """Ask a yes/no question and return True for yes, False for no."""
    while True:
        answer = input(f"{question} (yes/no): ").strip().lower()
        if answer in ("yes", "y"):
            return True
        elif answer in ("no", "n"):
            return False
        else:
            print("Please answer yes or no.")


def main():
    print("Welcome to the Sky Decision App 🌤️\n")

    if ask_yes_no("Is the sky blue?"):
        print("\n👉 Suggestion: Put on sunglasses 😎")
        return

    if ask_yes_no("Is the sky gray?"):
        print("\n👉 Suggestion: Put on a rain coat... 🌧️")
        return

    if ask_yes_no("Is the sky green?"):
        print("\n👉 Suggestion: Hide 🫣")
        return

    if ask_yes_no("Is the sky black?"):
        print("\n👉 Suggestion: Make a bonfire 🔥")
        return

    print("\n👉 Suggestion: Do something else 🤷")


if __name__ == "__main__":
    main()
