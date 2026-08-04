# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import template with context %}

install_packages:
  pkg.installed:
    - pkgs: {{ template.pkg.name | yaml }}

create_group:
  group.present:
    - name: {{ template.app.group }}
    - system: true

create_user:
  user.present:
    - name: {{ template.app.user }}
    - gid: {{ template.app.group }}
    - home: /home/{{ template.app.user }}
    - shell: /usr/sbin/nologin
    - system: true
    - require:
      - group: create_group

{{ template.service.name }}_service:
  service.running:
    - name: {{ template.service.name }}
    - enable: {{ template.service.enable }}
    # Requisites (not just top-to-bottom file order) are what actually
    # guarantee ordering in Salt: the service needs its package and the
    # user/group it should run as to exist first. Add a `watch` here on
    # any config file state you introduce (e.g. `file: app_config`) so
    # the service restarts when the config changes.
    - require:
      - pkg: install_packages
      - user: create_user
