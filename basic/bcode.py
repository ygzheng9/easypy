from elaphe import barcode


def get_barcode(info):
    a = barcode(
        'qrcode',
        info,
        options=dict(version=9, eclevel='M'),
        margin=10,
        data_mode='8bits')

    a.show()


if __name__ == '__main__':
    get_barcode("so easy")