from flask import Flask, request, jsonify
from bs4 import BeautifulSoup
import base64

app = Flask(__name__)


@app.route('/', methods=['Get'])
def test():
    return "hello"


@app.route('/generate_html', methods=['POST'])
def generate_html():
    data = request.json
    user_id = data.get('user_id')
    is_commic = data.get('is_commic')
    content = data.get('content')
    if is_commic:
        output_html_file_name = make_manga_html(user_id, content)
    else:
        output_html_file_name = make_ehon_html(user_id, content)
    if output_html_file_name:
        with open(output_html_file_name, 'rb') as f:
            output_html = f.read()
        output_base64 = base64.b64encode(output_html).decode('utf-8')
    return jsonify({'output_html_base64': output_base64})


def make_ehon_html(id, content):
    input_file_name = 'html_template/ehon_template.html'
    with open(input_file_name, 'r', encoding='utf-8') as file:
        html_content = file.read()

    soup = BeautifulSoup(html_content, 'lxml')

    if soup.title:
        soup.title.string = f"{id}"
    # 画像の編集
    for i in [1, 2]:
        target_img = soup.find('img', id=f"img_{i}")
        if target_img:
            target_img['src'] = "data:image/png;base64," + content[f"img_src_{i}"]
    # ナレーションの編集
    target_p = soup.find('p')
    if target_p:
        narration_html = BeautifulSoup(content["text"], 'html.parser')
        target_p.append(narration_html)

    output_file_name = f"output/{id}.html"
    with open(output_file_name, 'w', encoding='utf-8') as file:
        file.write(str(soup))
    return output_file_name


def make_manga_html(id, content_list):
    input_file_name = 'html_template/manga_template.html'
    with open(input_file_name, 'r', encoding='utf-8') as file:
        html_content = file.read()

    soup = BeautifulSoup(html_content, 'lxml')

    if soup.title:
        soup.title.string = f"{id}"

    for i, content in enumerate(content_list, start=1):
        # 画像の編集
        target_img = soup.find('img', id=f"panel_{i}")
        if target_img:
            target_img['src'] = "data:image/png;base64," + content["img_src"]
        # ナレーションの編集
        target_text_div = soup.find('div', id=f"panel_{i}")
        if target_text_div:
            target_text_div.string = content["text"]

    output_file_name = f"output/{id}.html"
    with open(output_file_name, 'w', encoding='utf-8') as file:
        file.write(str(soup))
    return output_file_name


if __name__ == '__main__':
    app.run()
