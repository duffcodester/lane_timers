module ApplicationHelper
  def bookings_sort_link(label, column)
    direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"
    default   = params[:sort].blank? && column == "start_time"
    indicator = ""
    if params[:sort] == column || default
      indicator = (params[:direction] == "desc" && params[:sort] == column) ? " \u25BC" : " \u25B2"
    end
    url_params = { sort: column, direction: direction, page: 1 }
    url_params[:filter_active] = 1                     if params[:filter_active].present?
    url_params[:club_ids]      = params[:club_ids]     if params[:club_ids].present?
    url_params[:search]        = params[:search]       if params[:search].present?
    link_to "#{label}#{indicator}".html_safe,
            list_bookings_path(url_params),
            class: "sort-link"
  end

  def sort_link(label, column)
    direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"
    indicator = ""
    if params[:sort] == column || (params[:sort].blank? && column == "name")
      indicator = (params[:direction] == "desc" || (params[:sort].blank? && column == "name" && params[:direction] != "desc")) ? " \u25B2" : " \u25BC"
      if params[:sort] == column && params[:direction] == "desc"
        indicator = " \u25BC"
      elsif params[:sort] == column && params[:direction] == "asc"
        indicator = " \u25B2"
      else
        indicator = " \u25B2"
      end
    end
    link_to "#{label}#{indicator}".html_safe, clubs_path(sort: column, direction: direction, search: params[:search], page: 1), class: "sort-link"
  end
end
